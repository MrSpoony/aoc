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
  let assert Ok(input) = simplifile.read("inputs/input06.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Direction {
  North
  East
  South
  West
}

fn turn_right(dir: Direction) {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn parse(input: String) {
  let grid =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      line
      |> list.index_fold(dict.new(), fn(acc, cell, j) {
        dict.insert(acc, #(i, j), cell)
      })
      |> dict.merge(acc)
    })
  let assert Ok(#(i, j)) =
    grid
    |> dict.fold(Error(Nil), fn(acc, pos, cell) {
      acc
      |> result.or(case cell {
        "^" -> Ok(pos)
        _ -> Error(Nil)
      })
    })

  let direction = North

  #(grid, #(i, j), direction)
}

// I don't want to optimize this, I just want to get it done
fn walk_p1(
  grid: Dict(#(Int, Int), String),
  pos: #(Int, Int),
  dir: Direction,
  seen: Set(#(Int, Int)),
) {
  let #(i, j) = pos
  let new_pos = case dir {
    North -> #(i - 1, j)
    East -> #(i, j + 1)
    South -> #(i + 1, j)
    West -> #(i, j - 1)
  }
  let seen = set.insert(seen, pos)
  case dict.get(grid, new_pos) {
    Ok("#") -> walk_p1(grid, pos, turn_right(dir), seen)
    Error(Nil) -> seen
    _ -> walk_p1(grid, new_pos, dir, seen)
  }
}

fn walk_p2(
  grid: Dict(#(Int, Int), String),
  pos: #(Int, Int),
  dir: Direction,
  seen: Set(#(Int, Int, Direction)),
) {
  let #(i, j) = pos
  let new_pos = case dir {
    North -> #(i - 1, j)
    East -> #(i, j + 1)
    South -> #(i + 1, j)
    West -> #(i, j - 1)
  }
  case set.contains(seen, #(i, j, dir)) {
    True -> True
    False -> {
      let seen = set.insert(seen, #(i, j, dir))
      case dict.get(grid, new_pos) {
        Ok("#") -> walk_p2(grid, pos, turn_right(dir), seen)
        Error(Nil) -> False
        _ -> walk_p2(grid, new_pos, dir, seen)
      }
    }
  }
}

pub fn part1(input: String) {
  let #(grid, pos, dir) = parse(input)
  let seen = walk_p1(grid, pos, dir, set.new())
  set.size(seen)
}

// I really don't have the time to optimize this currently
// I know that this is hella slow for bigger inputs (O((n*m)^2)
pub fn part2(input: String) {
  let #(grid, pos, dir) = parse(input)
  let height = input |> string.trim |> string.split("\n") |> list.length
  let width =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.first()
    |> result.unwrap("")
    |> string.length
  list.range(0, height - 1)
  |> list.fold(0, fn(acc, i) {
    list.range(0, width - 1)
    |> list.fold(acc, fn(acc, j) {
      case dict.get(grid, #(i, j)) {
        Ok("#") | Ok("^") -> acc
        _ -> {
          let grid = dict.insert(grid, #(i, j), "#")
          acc + bool.to_int(walk_p2(grid, pos, dir, set.new()))
        }
      }
    })
  })
}
