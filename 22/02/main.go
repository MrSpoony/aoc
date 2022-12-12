package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	file, _ := ioutil.ReadFile("input.txt")
	lines := strings.Split(string(file), "\n")
	games := make([][]string, len(lines))
	for i, line := range lines {
		games[i] = strings.Split(line, " ")
	}
	fmt.Println(calculateScore(games))
	prepare(games)
	fmt.Println(calculateScore(games))
}

func prepare(games [][]string) {
	for i, game := range games {
		if len(game) != 2 {
			continue
		}
		switch game[1] {
		case "X":
			switch game[0] {
			case "A":
				games[i][1] = "Z"
			case "B":
				games[i][1] = "X"
			case "C":
				games[i][1] = "Y"
			}
		case "Y":
			switch game[0] {
			case "A":
				games[i][1] = "X"
			case "B":
				games[i][1] = "Y"
			case "C":
				games[i][1] = "Z"
			}
		case "Z":
			switch game[0] {
			case "A":
				games[i][1] = "Y"
			case "B":
				games[i][1] = "Z"
			case "C":
				games[i][1] = "X"
			}
		}
	}
}

func calculateScore(games [][]string) (res int) {
	for _, game := range games {
		if len(game) != 2 {
			continue
		}
		switch game[1] {
		case "X":
			res += 1
			switch game[0] {
			case "A":
				res += 3
			case "B":
			case "C":
				res += 6
			}
		case "Y":
			res += 2
			switch game[0] {
			case "A":
				res += 6
			case "B":
				res += 3
			case "C":
			}
		case "Z":
			res += 3
			switch game[0] {
			case "A":
			case "B":
				res += 6
			case "C":
				res += 3
			}
		}
	}

	return
}
