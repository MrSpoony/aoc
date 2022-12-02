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
	res := 0
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
	fmt.Println(res)
}
