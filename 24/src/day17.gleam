import gleam/bool
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("inputs/input17.txt")
  part1(input) |> io.println
  part2(input) |> int.to_string |> io.println
}

type Memory {
  Memory(a: Int, b: Int, c: Int, ip: Int, out: List(Int))
}

fn parse(input: String) {
  let assert Ok(#(regs, program)) =
    input |> string.trim |> string.split_once("\n\n")
  let assert Ok(program) =
    program
    |> string.drop_start(string.length("Program: "))
    |> string.split(",")
    |> list.map(int.parse)
    |> result.all
  let assert Ok(regs) =
    regs
    |> string.split("\n")
    |> list.map(fn(s) {
      s |> string.drop_start(string.length("Register X: ")) |> int.parse
    })
    |> result.all
  let assert Ok(a) = regs |> list.first
  let assert Ok(b) = regs |> list.drop(1) |> list.first
  let assert Ok(c) = regs |> list.drop(2) |> list.first
  #(Memory(a, b, c, 0, []), program)
}

fn get_num(operand: Int, mem: Memory) {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> mem.a
    5 -> mem.b
    6 -> mem.c
    _ -> panic as "only accepts 3-bit numbers"
  }
}

fn operate(opcode: Int, operand: Int, mem: Memory) {
  let Memory(a, b, c, _, out) = mem
  case opcode {
    0 -> Memory(..mem, a: int.bitwise_shift_right(a, get_num(operand, mem)))
    1 -> Memory(..mem, b: int.bitwise_exclusive_or(b, operand))
    2 -> Memory(..mem, b: get_num(operand, mem) % 8)
    3 -> bool.guard(a == 0, mem, fn() { Memory(..mem, ip: operand) })
    4 -> Memory(..mem, b: int.bitwise_exclusive_or(b, c))
    5 -> Memory(..mem, out: [get_num(operand, mem) % 8, ..out])
    6 -> Memory(..mem, b: int.bitwise_shift_right(a, get_num(operand, mem)))
    7 -> Memory(..mem, c: int.bitwise_shift_right(a, get_num(operand, mem)))
    _ -> panic as "only accepts 3-bit numbers"
  }
}

fn run(allops: List(Int), mem: Memory) {
  case allops |> list.drop(mem.ip) {
    [opcode, operand, ..] -> {
      let newmem = operate(opcode, operand, mem)
      let ipinc = bool.to_int(newmem.ip == mem.ip) * 2
      run(allops, Memory(..newmem, ip: newmem.ip + ipinc))
    }
    _ -> mem
  }
}

// In my input every number depends on the last 7+3=10 bits (after manual inspection),
// This means it also affects the last 4 numbers, that must match
// So i try all combinations for the last 4 numbers, until they match,
// and go on to the next number afterwards
fn find_a(allops: List(Int), mem: Memory, rest: List(Int), last_a: Int) {
  case rest {
    [head, second, third, fourth, ..rest] -> {
      let new_a =
        list.range(0, 8 * 8 * 8 * 8)
        |> list.find_map(fn(candidate) {
          let new_a = last_a * 8 + candidate
          let newmem = run(allops, Memory(..mem, a: new_a))
          let newout = newmem.out |> list.reverse |> list.take(4)
          case newout == [fourth, third, second, head] {
            True -> Ok(new_a)
            False -> Error(Nil)
          }
        })
        |> result.lazy_unwrap(fn() {
          panic as "shouldn't happen (famous last words)"
        })
      find_a(allops, mem, [second, third, fourth, ..rest], new_a)
    }
    // Last 3 numbers were already matched
    _ -> last_a
  }
}

pub fn part1(input: String) {
  let #(mem, program) = parse(input)
  let regs = run(program, mem)
  regs.out |> list.reverse |> list.map(int.to_string) |> string.join(",")
}

pub fn part2(input: String) {
  let #(mem, program) = parse(input)
  let a = find_a(program, mem, program |> list.reverse, 0)
  let assert True =
    run(program, Memory(..mem, a: a)).out
    |> list.reverse
    == program
  a
}
// Program: 2,4,1,2,7,5,4,3,0,3,1,7,5,5,3,0
//
// for (ll A = A; A > 0; A /= 8) {
//   ll B = A % 8
//   ll B = B ^ 2
//   ll C = A >> B
//   ll B = B^C
//   ll B = B^7
//   printf(B % 8)
// }
//
// for (ll A = A; A > 0; A /= 8) {
//   ll B = A % 8
//   ll B = B ^ 2
//   printf((((B ^ (A >> B)) ^ 7) % 3)
//                       ^ could be max 7
//                         but I only need last 3 bits
//                         using 7+3 = 10 last bits of A
//                         affects last 4 numbers
// }
