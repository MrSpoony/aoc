import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input12.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Pos {
  Pos(x: Int, y: Int)
}

type Direction {
  Up
  Right
  Down
  Left
}

fn adjacient_pos(v: Pos) {
  [Pos(v.x - 1, v.y), Pos(v.x + 1, v.y), Pos(v.x, v.y - 1), Pos(v.x, v.y + 1)]
}

fn walk_to(pos: Pos, dir: Direction) {
  case dir {
    Up -> Pos(pos.x - 1, pos.y)
    Right -> Pos(pos.x, pos.y + 1)
    Down -> Pos(pos.x + 1, pos.y)
    Left -> Pos(pos.x, pos.y - 1)
  }
}

fn right(dir: Direction) {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn left(dir: Direction) {
  dir |> right |> right |> right
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(acc, line, i) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, j) {
      dict.insert(acc, Pos(i, j), char)
    })
  })
}

fn get_cell_perimiter(map: Dict(Pos, String), v: Pos) {
  let assert Ok(cur) = map |> dict.get(v)
  adjacient_pos(v)
  |> list.map(fn(pos) { map |> dict.get(pos) |> result.unwrap(".") })
  |> list.map(fn(char) { char != cur })
  |> list.map(bool.to_int)
  |> int.sum
}

fn dfs_p1(map: Dict(Pos, String), v: Pos, char: String, vis: Set(Pos)) {
  use <- bool.guard(set.contains(vis, v), #(0, 0, vis))
  use <- bool.guard(dict.get(map, v) |> result.unwrap(".") != char, #(0, 0, vis))
  let vis = set.insert(vis, v)
  adjacient_pos(v)
  |> list.fold(#(1, get_cell_perimiter(map, v), vis), fn(acc, pos) {
    let #(acc_area, acc_peri, vis) = acc
    let #(area, peri, vis) = dfs_p1(map, pos, char, vis)
    #(acc_area + area, acc_peri + peri, vis)
  })
}

fn get_area(map: Dict(Pos, String), v: Pos, char: String, vis: Set(Pos)) {
  use <- bool.guard(set.contains(vis, v), #(0, vis))
  use <- bool.guard(dict.get(map, v) != Ok(char), #(0, vis))
  let vis = set.insert(vis, v)
  adjacient_pos(v)
  |> list.fold(#(1, vis), fn(acc, pos) {
    let #(acc_area, vis) = acc
    let #(area, vis) = get_area(map, pos, char, vis)
    #(acc_area + area, vis)
  })
}

// walking counterclockwise around the perimiter
fn walk_peri(
  map: Dict(Pos, String),
  v: Pos,
  char: String,
  dir: Direction,
  vis: Set(#(Pos, Direction)),
) {
  use <- bool.guard(dict.get(map, v) != Ok(char), #(0, vis))
  use <- bool.guard(set.contains(vis, #(v, dir)), #(0, vis))
  let vis = set.insert(vis, #(v, dir))
  // check if walk in direction is still valid
  let next = v |> walk_to(dir)
  use <- bool.lazy_guard(dict.get(map, next) != Ok(char), fn() {
    // turn left and continue search
    let #(length, vis) = walk_peri(map, v, char, dir |> left, vis)
    #(length + 1, vis)
  })
  let to_check = next |> walk_to(dir |> right)
  use <- bool.lazy_guard(dict.get(map, to_check) == Ok(char), fn() {
    // turn right and continue search
    let #(length, vis) = walk_peri(map, to_check, char, dir |> right, vis)
    #(length + 1, vis)
  })

  // continue straight
  walk_peri(map, next, char, dir, vis)
}

fn find_perimiter(
  map: Dict(Pos, String),
  v: Pos,
  char: String,
  vis: Set(#(Pos, Direction)),
) {
  case dict.get(map, walk_to(v, Right)) == Ok(char) {
    True -> find_perimiter(map, walk_to(v, Right), char, vis)
    False -> walk_peri(map, v, char, Up, vis)
  }
}

pub fn part1(input: String) {
  let map = parse(input)
  let #(res, _) =
    map
    |> dict.fold(#(0, set.new()), fn(acc, pos, char) {
      let #(sum, vis) = acc
      let #(area, peri, vis) = dfs_p1(map, pos, char, vis)
      #(sum + area * peri, vis)
    })
  res
}

pub fn part2(input: String) {
  let map = parse(input)
  let #(res, _) =
    map
    |> dict.fold(#(0, set.new()), fn(acc, pos, char) {
      let #(sum, oldvis) = acc
      let #(area, vis) = get_area(map, pos, char, oldvis)
      // I know that this is very slow but I didn't want to come up
      // with a better alternative for the inner perimiters
      let diff = set.difference(vis, oldvis)
      let #(peri, _) =
        diff
        |> set.fold(#(0, set.new()), fn(acc, pos) {
          let #(acc_peri, vis) = acc
          let #(perimiter, vis) = find_perimiter(map, pos, char, vis)
          #(acc_peri + perimiter, vis)
        })
      #(sum + area * peri, vis)
    })
  res
}
