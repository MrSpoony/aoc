import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input09.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type LengthIndicator {
  File(index: Int, length: Int)
  Free(Int)
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.to_graphemes
  |> list.index_map(fn(x, i) {
    let assert Ok(x) = int.parse(x)
    case int.modulo(i, 2) {
      Ok(0) -> File(i / 2, x)
      Ok(1) -> Free(x)
      _ -> Free(0)
    }
  })
}

fn sum_from_up(from: Int, delta: Int) {
  { { delta } * { 2 * from + delta - 1 } } / 2
}

fn solve_p1(disk: Deque(LengthIndicator), index: Int) {
  case deque.pop_front(disk) {
    Ok(#(head, rest)) ->
      case head {
        File(idx, len) ->
          sum_from_up(index, len) * idx + solve_p1(rest, index + len)
        Free(len_free) ->
          case deque.pop_back(rest) {
            Ok(#(last, rest)) ->
              case last {
                File(idx, len_last) if len_last < len_free ->
                  sum_from_up(index, len_last)
                  * idx
                  + solve_p1(
                    deque.push_front(rest, Free(len_free - len_last)),
                    index + len_last,
                  )
                File(idx, len_last) ->
                  sum_from_up(index, len_free)
                  * idx
                  + solve_p1(
                    deque.push_back(rest, File(idx, len_last - len_free)),
                    index + len_free,
                  )
                Free(_) ->
                  solve_p1(deque.push_front(rest, Free(len_free)), index)
              }
            Error(Nil) -> 0
          }
      }
    Error(Nil) -> 0
  }
}

fn fill_hole(disk: Deque(LengthIndicator), hole: Int) {
  use #(head, rest) <- try(deque.pop_back(disk))
  case head {
    File(idx, len) if len <= hole ->
      Ok(#(
        idx,
        len,
        rest |> deque.push_back(Free(len)) |> deque.to_list |> list.reverse,
      ))
    _ ->
      fill_hole(rest, hole)
      |> result.map(fn(res) {
        let #(idx, len, rest) = res
        #(idx, len, [head, ..rest])
      })
  }
}

fn solve_p2(disk: Deque(LengthIndicator), index: Int) {
  case deque.pop_front(disk) {
    Ok(#(head, rest)) ->
      case head {
        File(idx, len) ->
          sum_from_up(index, len) * idx + solve_p2(rest, index + len)
        Free(len_free) -> {
          case fill_hole(rest, len_free) {
            Ok(#(idx, len, rest)) ->
              sum_from_up(index, len)
              * idx
              + solve_p2(
                rest
                  |> list.reverse
                  |> deque.from_list
                  |> deque.push_front(Free(len_free - len)),
                index + len,
              )
            Error(Nil) -> solve_p2(rest, index + len_free)
          }
        }
      }
    Error(Nil) -> 0
  }
}

pub fn part1(input: String) {
  let disk = parse(input)
  solve_p1(disk |> deque.from_list, 0)
}

pub fn part2(input: String) {
  let disk = parse(input)
  solve_p2(disk |> deque.from_list, 0)
}
