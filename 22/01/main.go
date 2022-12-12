package main

import (
	"fmt"
	"io/ioutil"
	"sort"
	"strconv"
	"strings"
)

func main() {
	maxi := -1
	contentb, _ := ioutil.ReadFile("input.txt")
	content := string(contentb)
	chunks := strings.Split(content, "\n\n")
	listChunks := make([]int, len(chunks))
	for i, chunk := range chunks {
		realChunk := strings.Split(chunk, "\n")
		curr := 0
		for _, line := range realChunk {
			x, err := strconv.Atoi(line)
			if err != nil {
				continue
			}
			curr += x
		}
		listChunks[i] = curr
		maxi = max(maxi, curr)
	}
	sort.Slice(listChunks, func(i, j int) bool {
		return listChunks[i] > listChunks[j]
	})
	res := sum(listChunks[:3])
	fmt.Println(maxi)
	fmt.Println(res)
}

func max(x, y int) int {
	if x > y {
		return x
	}
	return y
}

func sum(list []int) int {
	res := 0
	for _, x := range list {
		res += x
	}
	return res
}
