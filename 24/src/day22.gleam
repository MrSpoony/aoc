import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input22.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn calc(x: Int) {
  let x = int.bitwise_exclusive_or({ x * 64 }, x) % 16_777_216
  let x = int.bitwise_exclusive_or({ x / 32 }, x) % 16_777_216
  int.bitwise_exclusive_or({ x * 2048 }, x) % 16_777_216
}

fn calc_times(x: Int, times: Int) {
  list.range(1, times) |> list.fold(x, fn(x, _) { calc(x) })
}

pub fn part1(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.try_map(int.parse)
  |> result.map(list.map(_, calc_times(_, 2000)))
  |> result.unwrap([-1])
  |> int.sum
}

pub fn part2(input: String) {
  let _digits_with_diffs =
    input
    |> string.trim
    |> string.split("\n")
    |> list.try_map(int.parse)
    |> result.unwrap([])
    |> list.map(fn(n) {
      let ns =
        list.range(1, 2000)
        |> list.scan(n, fn(x, _) { calc(x) })
        |> list.prepend(n)
        |> list.map(fn(x) { x % 10 })

      list.zip(
        ns
          |> list.window_by_2()
          |> list.map(fn(p) { p.1 - p.0 })
          |> list.window(4),
        ns |> list.drop(4),
      )
    })
    |> list.map(fn(set) {
      set
      |> list.fold(dict.new(), fn(acc, p) {
        case acc |> dict.get(p.0) {
          Ok(_) -> acc
          Error(Nil) -> {
            acc |> dict.insert(p.0, p.1)
          }
        }
      })
    })
    |> list.fold(dict.new(), fn(acc, map) {
      map
      |> dict.fold(acc, fn(acc, set, val) {
        acc
        |> dict.upsert(set, fn(x) {
          case x {
            Some(v) -> v + val
            None -> val
          }
        })
      })
    })
    |> dict.to_list
    // |> list.map(io.debug)
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
    |> list.last
    |> result.unwrap(#([], 0))
    |> pair.second
}
