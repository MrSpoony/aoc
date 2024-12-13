import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Pos {
  Pos(x: Int, y: Int)
}

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input08.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  let input =
    input |> string.trim |> string.split("\n") |> list.map(string.to_graphemes)
  let height = input |> list.length
  let width = input |> list.first |> result.unwrap([]) |> list.length
  let map: Dict(String, Set(Pos)) =
    input
    |> list.index_fold(dict.new(), fn(acc, line, i) {
      line
      |> list.index_fold(acc, fn(acc, char, j) {
        case char {
          "." -> acc
          _ ->
            dict.upsert(acc, char, fn(x) {
              case x {
                None -> set.from_list([Pos(i, j)])
                Some(s) -> set.insert(s, Pos(i, j))
              }
            })
        }
      })
    })
  #(height, width, map)
}

fn run_part(input, gen_candidates) {
  let #(height, width, map) = parse(input)
  dict.values(map)
  |> list.flat_map(fn(x) {
    x
    |> set.to_list
    |> list.combination_pairs
    |> list.flat_map(fn(pair) {
      let #(a, b) = pair
      let d = Pos(a.x - b.x, a.y - b.y)
      gen_candidates(a, b, d, height, width)
      |> list.filter(fn(pos: Pos) {
        pos.x >= 0 && pos.x < height && pos.y >= 0 && pos.y < width
      })
    })
  })
  |> list.unique
  |> list.length
}

pub fn part1(input: String) {
  run_part(input, fn(a, b, d, _, _) {
    [Pos(a.x + d.x, a.y + d.y), Pos(b.x - d.x, b.y - d.y)]
    // extension to left&right
  })
}

pub fn part2(input: String) {
  run_part(input, fn(a, _, d, height, width) {
    let mindim = int.min(height, width)
    list.range(-mindim, mindim)
    |> list.map(fn(i) { Pos(a.x + d.x * i, a.y + d.y * i) })
    // extension until border
  })
}
