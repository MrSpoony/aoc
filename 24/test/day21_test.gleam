import day21
import gleeunit/should

const example = "
029A
980A
179A
456A
379A
"

pub fn part1_test() {
  day21.part1(example) |> should.equal(126_384)
}
