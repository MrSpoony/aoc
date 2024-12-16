import day16
import gleeunit/should

const example_1 = "
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
"

const example_2 = "
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
"

pub fn part1_ex1_test() {
  day16.part1(example_1) |> should.equal(7036)
}

pub fn part1_ex2_test() {
  day16.part1(example_2) |> should.equal(11_048)
}

pub fn part2_ex1_test() {
  day16.part2(example_1) |> should.equal(45)
}

pub fn part2_ex2_test() {
  day16.part2(example_2) |> should.equal(64)
}