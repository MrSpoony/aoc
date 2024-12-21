import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result.{try}
import gleam/string
import gleamy/priority_queue
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input21.txt")
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type PosKP1 {
  PkA
  P0
  P1
  P2
  P3
  P4
  P5
  P6
  P7
  P8
  P9
}

type PosDP1 {
  PdA
  PU
  PL
  PR
  PD
}

const pds = [PdA, PU, PL, PR, PD]

fn move_pk(k: PosKP1, by: PosDP1) -> Result(#(PosKP1, Result(PosKP1, Nil)), Nil) {
  case k, by {
    _, PdA -> Ok(#(k, Ok(k)))
    PkA, PU -> Ok(#(P3, Error(Nil)))
    PkA, PL -> Ok(#(P0, Error(Nil)))
    PkA, _ -> Error(Nil)
    P0, PU -> Ok(#(P2, Error(Nil)))
    P0, PR -> Ok(#(PkA, Error(Nil)))
    P0, _ -> Error(Nil)
    P1, PU -> Ok(#(P4, Error(Nil)))
    P1, PR -> Ok(#(P2, Error(Nil)))
    P1, _ -> Error(Nil)
    P2, PU -> Ok(#(P5, Error(Nil)))
    P2, PD -> Ok(#(P0, Error(Nil)))
    P2, PL -> Ok(#(P1, Error(Nil)))
    P2, PR -> Ok(#(P3, Error(Nil)))
    P3, PU -> Ok(#(P6, Error(Nil)))
    P3, PD -> Ok(#(PkA, Error(Nil)))
    P3, PL -> Ok(#(P2, Error(Nil)))
    P3, _ -> Error(Nil)
    P4, PU -> Ok(#(P7, Error(Nil)))
    P4, PD -> Ok(#(P1, Error(Nil)))
    P4, PR -> Ok(#(P5, Error(Nil)))
    P4, _ -> Error(Nil)
    P5, PU -> Ok(#(P8, Error(Nil)))
    P5, PD -> Ok(#(P2, Error(Nil)))
    P5, PR -> Ok(#(P6, Error(Nil)))
    P5, PL -> Ok(#(P4, Error(Nil)))
    P6, PU -> Ok(#(P9, Error(Nil)))
    P6, PD -> Ok(#(P3, Error(Nil)))
    P6, PL -> Ok(#(P5, Error(Nil)))
    P6, _ -> Error(Nil)
    P7, PD -> Ok(#(P4, Error(Nil)))
    P7, PR -> Ok(#(P8, Error(Nil)))
    P7, _ -> Error(Nil)
    P8, PD -> Ok(#(P5, Error(Nil)))
    P8, PR -> Ok(#(P9, Error(Nil)))
    P8, PL -> Ok(#(P7, Error(Nil)))
    P8, _ -> Error(Nil)
    P9, PD -> Ok(#(P6, Error(Nil)))
    P9, PL -> Ok(#(P8, Error(Nil)))
    P9, _ -> Error(Nil)
  }
}

fn move_pd(d: PosDP1, by: PosDP1) -> Result(#(PosDP1, Result(PosDP1, Nil)), Nil) {
  case d, by {
    _, PdA -> Ok(#(d, Ok(d)))
    PU, PD -> Ok(#(PD, Error(Nil)))
    PU, PR -> Ok(#(PdA, Error(Nil)))
    PU, _ -> Error(Nil)
    PL, PR -> Ok(#(PD, Error(Nil)))
    PL, _ -> Error(Nil)
    PD, PU -> Ok(#(PU, Error(Nil)))
    PD, PL -> Ok(#(PL, Error(Nil)))
    PD, PR -> Ok(#(PR, Error(Nil)))
    PD, _ -> Error(Nil)
    PR, PU -> Ok(#(PdA, Error(Nil)))
    PR, PL -> Ok(#(PD, Error(Nil)))
    PR, _ -> Error(Nil)
    PdA, PD -> Ok(#(PR, Error(Nil)))
    PdA, PL -> Ok(#(PU, Error(Nil)))
    PdA, _ -> Error(Nil)
  }
}

type StateP1 {
  StateP1(nums: List(PosKP1), k: PosKP1, d2: PosDP1, d1: PosDP1)
}

fn move_p1(state: StateP1, by: PosDP1) {
  use #(d1, to_move) <- try(move_pd(state.d1, by))
  let state = StateP1(..state, d1: d1)
  use <- bool.guard(to_move |> result.is_error, Ok(state))
  let assert Ok(to_move) = to_move
  use #(d2, to_move) <- try(move_pd(state.d2, to_move))
  let state = StateP1(..state, d2: d2)
  use <- bool.guard(to_move |> result.is_error, Ok(state))
  let assert Ok(to_move) = to_move
  use #(k, ans) <- try(move_pk(state.k, to_move))
  let state = StateP1(..state, k: k)
  Ok(
    StateP1(
      ..state,
      nums: state.nums
        |> list.append(ans |> result.map(fn(x) { [x] }) |> result.unwrap([])),
    ),
  )
}

fn dijkstra_p1(
  pq: priority_queue.Queue(#(StateP1, Int)),
  vis: Dict(StateP1, Int),
  end: List(PosKP1),
) {
  use #(#(cur, score), pq) <- try(pq |> priority_queue.pop())
  use <- bool.lazy_guard(
    {
      end |> list.take(cur.nums |> list.length) != cur.nums
      || case vis |> dict.get(cur) {
        Ok(other_score) -> other_score <= score
        _ -> False
      }
    },
    fn() { dijkstra_p1(pq, vis, end) },
  )

  let vis = vis |> dict.insert(cur, score)
  use <- bool.guard(cur.nums == end, Ok(#(cur, vis, score)))
  let pq =
    pds
    |> list.fold(pq, fn(pq, pd) {
      case cur |> move_p1(pd) {
        Ok(next) -> pq |> priority_queue.push(#(next, score + 1))
        _ -> pq
      }
    })
  dijkstra_p1(pq, vis, end)
}

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) {
    x
    |> string.to_graphemes
    |> list.map(fn(c) {
      case c {
        "0" -> P0
        "1" -> P1
        "2" -> P2
        "3" -> P3
        "4" -> P4
        "5" -> P5
        "6" -> P6
        "7" -> P7
        "8" -> P8
        "9" -> P9
        "A" -> PkA
        _ -> panic as "invalid input"
      }
    })
  })
}

fn to_int(k: PosKP1) {
  case k {
    P0 -> 0
    P1 -> 1
    P2 -> 2
    P3 -> 3
    P4 -> 4
    P5 -> 5
    P6 -> 6
    P7 -> 7
    P8 -> 8
    P9 -> 9
    _ -> panic as "not convertable"
  }
}

fn to_num(ks: List(PosKP1)) {
  ks
  |> list.filter(fn(x) { x != PkA })
  |> list.fold(0, fn(acc, x) { acc * 10 + to_int(x) })
}

pub fn part1(input: String) {
  input
  |> parse
  |> list.fold(0, fn(acc, line) {
    let pq =
      priority_queue.from_list([#(StateP1([], PkA, PdA, PdA), 0)], fn(a, b) {
        int.compare(a.1, b.1)
      })
    let assert Ok(res) = dijkstra_p1(pq, dict.new(), line)
    acc + res.2 * to_num(line)
  })
}

// you know that the rest (all that come before current) must be all 'A's
// so you could memoize it but i don't have the time for this rn
pub fn part2(input: String) {
  12
}
