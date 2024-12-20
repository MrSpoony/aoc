import day20
import gleeunit/should

const example = "
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"

pub fn part1_test() {
  day20.part1(example) |> should.equal(0)
}

pub fn part2_test() {
  day20.part2(example) |> should.equal(0)
}
