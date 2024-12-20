import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result.{try}
import gleam/string
import gleamy/priority_queue
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input20.txt")
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

fn add(p1: Pos, p2: Pos) -> Pos {
  Pos(p1.x + p2.x, p1.y + p2.y)
}

fn size(p: Pos) -> Int {
  int.absolute_value(p.x) + int.absolute_value(p.y)
}

fn move(p: Pos, d: Dir) {
  case d {
    North -> Pos(p.x - 1, p.y)
    South -> Pos(p.x + 1, p.y)
    East -> Pos(p.x, p.y + 1)
    West -> Pos(p.x, p.y - 1)
  }
}

const dirs = [North, South, East, West]

fn parse(input: String) {
  let input =
    input
    |> string.trim
  let height = input |> string.split("\n") |> list.length
  let width =
    input
    |> string.split("\n")
    |> list.first
    |> result.unwrap("")
    |> string.length
  let grid =
    input
    |> string.split("\n")
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc, c, j) { acc |> dict.insert(Pos(i, j), c) })
    })
  let find = fn(c) {
    grid
    |> dict.to_list
    |> list.find(fn(x) { x.1 == c })
    |> result.unwrap(#(Pos(-1, -1), ""))
    |> pair.first()
  }
  let start = find("S")
  let end = find("E")
  #(grid, Pos(height, width), start, end)
}

fn dijkstra(
  grid: Dict(Pos, String),
  pq: priority_queue.Queue(#(Pos, Int)),
  vis: Dict(Pos, Int),
  end: Pos,
  dim: Pos,
) {
  use #(#(cur, score), pq) <- try(pq |> priority_queue.pop())
  use <- bool.lazy_guard(
    cur.x < 0
      || cur.y < 0
      || cur.x > dim.x
      || cur.y > dim.y
      || case vis |> dict.get(cur) {
      Ok(other_score) -> other_score <= score
      Error(Nil) -> False
    }
      || case grid |> dict.get(cur) {
      Ok("#") -> True
      _ -> False
    },
    fn() { dijkstra(grid, pq, vis, end, dim) },
  )
  let vis = vis |> dict.insert(cur, score)
  use <- bool.lazy_guard(cur == end, fn() {
    let vis = case dijkstra(grid, pq, vis, end, dim) {
      Ok(#(vis, _)) -> vis
      _ -> vis
    }
    Ok(#(vis, score))
  })
  let pq =
    dirs
    |> list.fold(pq, fn(pq, dir) {
      pq |> priority_queue.push(#(cur |> move(dir), score + 1))
    })
  dijkstra(grid, pq, vis, end, dim)
}

fn unique_paths(length: Int) {
  list.range(-length, length)
  |> list.fold([], fn(acc, i) {
    list.range(-length, length)
    |> list.fold(acc, fn(acc, j) {
      case Pos(i, j) |> size <= length {
        True -> [Pos(i, j), ..acc]
        False -> acc
      }
    })
  })
  |> list.unique
}

fn solve(input: String, length: Int) {
  let #(grid, dim, start, end) = parse(input)
  let pq =
    priority_queue.from_list([#(end, 0)], fn(a, b) { int.compare(a.1, b.1) })
  let assert Ok(#(vis_from_end, score_end)) =
    dijkstra(grid, pq, dict.new(), start, dim)
  let pq =
    priority_queue.from_list([#(start, 0)], fn(a, b) { int.compare(a.1, b.1) })
  let assert Ok(#(vis_from_start, score_start)) =
    dijkstra(grid, pq, dict.new(), end, dim)
  let assert True = score_start == score_end
  let vis_end_list =
    vis_from_end
    |> dict.to_list
  use acc, entry <- list.fold(vis_end_list, 0)
  let #(end_pos, end_score) = entry
  use acc, dir <- list.fold(unique_paths(length), acc)
  let start_pos = end_pos |> add(dir)
  let start_score =
    vis_from_start
    |> dict.get(start_pos)
    |> result.unwrap(10_000 * dim.x * dim.y)
  let new_score = start_score + end_score
  let saved = score_start - new_score - { dir |> size }
  case saved >= 100 {
    True -> acc + 1
    False -> acc
  }
}

pub fn part1(input: String) {
  solve(input, 2)
}

pub fn part2(input: String) {
  solve(input, 20)
}
