import day04
import gleeunit/should

const example = "
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
    "

pub fn diagonals_test() {
  day04.create_diagonals([[1, 2], [3, 4]], 1)
  |> should.equal([[1], [2, 3], [4]])

  day04.create_diagonals([[1, 2], [3, 4], [5, 6]], 1)
  |> should.equal([[1], [2, 3], [4, 5], [6]])

  day04.create_diagonals([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]], 1)
  |> should.equal([[1], [2, 4], [3, 5, 7], [6, 8, 10], [9, 11], [12]])
}

pub fn part1_test() {
  day04.part1(example)
  |> should.equal(18)
}

pub fn part2_test() {
  day04.part2(example)
  |> should.equal(9)
}
