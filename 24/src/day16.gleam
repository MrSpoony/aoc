import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import gleamy/priority_queue
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input16.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Pos {
  Pos(x: Int, y: Int)
}

type Dir {
  North
  South
  East
  West
}

fn right(d: Dir) {
  case d {
    North -> East
    South -> West
    East -> South
    West -> North
  }
}

fn left(d: Dir) {
  d |> right |> right |> right
}

fn move(p: Pos, d: Dir) {
  case d {
    North -> Pos(p.x - 1, p.y)
    South -> Pos(p.x + 1, p.y)
    East -> Pos(p.x, p.y + 1)
    West -> Pos(p.x, p.y - 1)
  }
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), Pos(0, 0)), fn(acc, line, i) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, j) {
      let newdict = dict.insert(acc.0, Pos(i, j), char)
      case char {
        "S" -> #(newdict, Pos(i, j))
        _ -> #(newdict, acc.1)
      }
    })
  })
}

fn dfs(
  grid: Dict(Pos, String),
  pq: priority_queue.Queue(#(Pos, Dir, Int)),
  vis: Dict(#(Pos, Dir), Int),
) {
  use #(#(cur, dir, score), pq) <- try(priority_queue.pop(pq))
  use <- bool.lazy_guard(
    vis |> dict.get(#(cur, dir)) |> result.map(int.max(_, score)) == Ok(score),
    fn() { dfs(grid, pq, vis) },
  )
  let vis = vis |> dict.insert(#(cur, dir), score)
  case grid |> dict.get(cur) {
    Ok(".") | Ok("S") -> {
      let pq =
        pq
        |> priority_queue.push(#(cur |> move(dir), dir, score + 1))
        |> priority_queue.push(#(cur, right(dir), score + 1000))
        |> priority_queue.push(#(cur, left(dir), score + 1000))
      dfs(grid, pq, vis)
    }
    Ok("E") -> Ok(score)
    _ -> {
      dfs(grid, pq, vis)
    }
  }
}

pub fn part1(input: String) {
  let #(grid, start) = parse(input)
  io.debug("")
  let pq =
    priority_queue.from_list([#(start, East, 0)], fn(a, b) {
      let #(_, _, a_score) = a
      let #(_, _, b_score) = b
      int.compare(a_score, b_score)
    })
  let assert Ok(res) = dfs(grid, pq, dict.new())
  res
}

pub fn part2(input: String) {
  12
}
