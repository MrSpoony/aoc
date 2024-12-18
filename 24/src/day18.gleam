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
  let assert Ok(input) = simplifile.read("inputs/input18.txt")
  part1(input, #(70, 70), 1024) |> int.to_string |> io.println
  part2(input, #(70, 70)) |> io.println
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

const dirs = [North, South, East, West]

fn move(p: Pos, d: Dir) {
  case d {
    North -> Pos(p.x - 1, p.y)
    South -> Pos(p.x + 1, p.y)
    East -> Pos(p.x, p.y + 1)
    West -> Pos(p.x, p.y - 1)
  }
}

fn parse(input: String) {
  let assert Ok(nums) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(x, y)) = line |> string.split_once(",")
      use x <- try(x |> int.parse())
      use y <- try(y |> int.parse())
      Ok(Pos(x, y))
    })
    |> result.all
  nums
  |> list.zip(list.range(0, list.length(nums) - 1))
  |> dict.from_list
}

fn dijkstra(
  grid: Dict(Pos, Int),
  pq: priority_queue.Queue(#(Pos, Int)),
  vis: Dict(Pos, Int),
  threshold: Int,
  end: Pos,
) {
  use #(#(cur, score), pq) <- try(pq |> priority_queue.pop())
  use <- bool.lazy_guard(
    {
      cur.x < 0
      || cur.y < 0
      || cur.x > end.x
      || cur.y > end.y
      || case vis |> dict.get(cur) {
        Ok(other_score) -> other_score <= score
        Error(Nil) -> False
      }
      || case grid |> dict.get(cur) {
        Ok(x) if x < threshold -> True
        _ -> False
      }
    },
    fn() { dijkstra(grid, pq, vis, threshold, end) },
  )
  use <- bool.guard(cur == end, Ok(score))

  let vis = vis |> dict.insert(cur, score)
  let pq =
    dirs
    |> list.fold(pq, fn(pq, dir) {
      case vis |> dict.get(cur |> move(dir)) {
        Ok(_) -> pq
        _ -> pq |> priority_queue.push(#(cur |> move(dir), score + 1))
      }
    })
  dijkstra(grid, pq, vis, threshold, end)
}

fn binary_search(l: Int, r: Int, grid: Dict(Pos, Int), dim: #(Int, Int)) {
  let m = { l + r } / 2
  use <- bool.guard(r - l <= 1, l)
  let pq =
    priority_queue.from_list([#(Pos(0, 0), 0)], fn(a, b) {
      int.compare(a |> pair.second, b |> pair.second)
    })
  case dijkstra(grid, pq, dict.new(), m, Pos(dim.0, dim.1)) {
    Ok(_) -> binary_search(m, r, grid, dim)
    Error(Nil) -> binary_search(l, m, grid, dim)
  }
}

pub fn part1(input: String, dim: #(Int, Int), threshold: Int) {
  let grid = parse(input)
  let pq =
    priority_queue.from_list([#(Pos(0, 0), 0)], fn(a, b) {
      int.compare(a |> pair.second, b |> pair.second)
    })
  dijkstra(grid, pq, dict.new(), threshold, Pos(dim.0, dim.1))
  |> result.unwrap(-1)
}

pub fn part2(input: String, dim: #(Int, Int)) {
  let grid = parse(input)
  let idx = binary_search(0, grid |> dict.size, grid, dim)
  let assert Ok(pos) = grid |> dict.to_list |> list.find(fn(it) { it.1 == idx })
  { pos.0 }.x |> int.to_string <> "," <> { pos.0 }.y |> int.to_string
}
