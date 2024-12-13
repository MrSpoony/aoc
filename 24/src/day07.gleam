import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input07.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(left, right)) = string.split_once(line, ": ")
    let assert Ok(left) = int.parse(left)
    #(left, right |> string.split(" ") |> list.filter_map(int.parse))
  })
}

fn try_p1(nums: List(Int), acc: Int, res: Int) {
  case nums {
    [] -> acc == res
    [n, ..rest] -> {
      case acc + n {
        x if x > res -> False
        x -> try_p1(rest, x, res)
      }
      || case acc * n {
        x if x > res -> False
        x -> try_p1(rest, x, res)
      }
    }
  }
}

fn concat(a: Int, b: Int) {
  string.append(int.to_string(a), int.to_string(b))
  |> int.parse
  |> result.unwrap(0)
}

fn try_p2(nums: List(Int), acc: Int, res: Int) {
  case nums {
    [] -> acc == res
    [n, ..rest] -> {
      case acc + n {
        x if x > res -> False
        x -> try_p2(rest, x, res)
      }
      || case acc * n {
        x if x > res -> False
        x -> try_p2(rest, x, res)
      }
      || case concat(acc, n) {
        x if x > res -> False
        x -> try_p2(rest, x, res)
      }
    }
  }
}

pub fn part1(input: String) {
  parse(input)
  |> list.fold(0, fn(acc, line) {
    let #(res, nums) = line
    acc
    + case try_p1(nums, 0, res) {
      True -> res
      False -> 0
    }
  })
}

pub fn part2(input: String) {
  parse(input)
  |> list.fold(0, fn(acc, line) {
    let #(res, nums) = line
    acc
    + case try_p2(nums, 0, res) {
      True -> res
      False -> 0
    }
  })
}
