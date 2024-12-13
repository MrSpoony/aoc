import gleam/bool.{guard}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input10.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Pos {
  Pos(x: Int, y: Int)
}

fn parse_fold(input: String, initial: a, f: fn(a, Dict(Pos, Int), Pos) -> a) {
  let lines = input |> string.trim |> string.split("\n")
  let height = lines |> list.length
  let width =
    lines
    |> list.first
    |> result.unwrap("")
    |> string.length()
  let map =
    lines
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      line
      |> string.to_graphemes
      |> list.index_fold(acc, fn(acc, char, j) {
        let assert Ok(num) = int.parse(char)
        dict.insert(acc, Pos(i, j), num)
      })
    })
  // Not sure if I like this syntax
  use acc, i <- list.fold(list.range(0, height - 1), initial)
  use acc, j <- list.fold(list.range(0, width - 1), acc)
  f(acc, map, Pos(i, j))
}

fn dfs(map: Dict(Pos, Int), pos: Pos, num: Int, vis: Set(Pos), part: Int) {
  use <- guard(part == 1 && set.contains(vis, pos), #(0, vis))
  use <- guard(map |> dict.get(pos) |> result.unwrap(-1) != num, #(0, vis))
  use <- guard(num == 9, #(1, set.insert(vis, pos)))
  let #(right, vis) = dfs(map, Pos(pos.x + 1, pos.y), num + 1, vis, part)
  let #(left, vis) = dfs(map, Pos(pos.x - 1, pos.y), num + 1, vis, part)
  let #(down, vis) = dfs(map, Pos(pos.x, pos.y + 1), num + 1, vis, part)
  let #(up, vis) = dfs(map, Pos(pos.x, pos.y - 1), num + 1, vis, part)
  #(right + left + up + down, vis)
}

pub fn part1(input: String) {
  parse_fold(input, 0, fn(acc, map, pos) {
    acc + dfs(map, pos, 0, set.new(), 1).0
  })
}

pub fn part2(input: String) {
  parse_fold(input, 0, fn(acc, map, pos) {
    acc + dfs(map, pos, 0, set.new(), 2).0
  })
}
