package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type Node struct {
	Name     string
	Children map[string]*Node
	Size     int
}

func (n *Node) MoveTo(path []string) *Node {
	curr := n
	for _, dir := range path {
		curr = curr.Children[dir]
	}
	return curr
}

func (n *Node) IsDir() bool {
	return len(n.Children) > 0
}

func (n *Node) CalculateSize() int {
	for _, child := range n.Children {
		n.Size += child.CalculateSize()
	}
	return n.Size
}

func (n *Node) MaxToClean(x int) int {
	canClean := 0
	if n.Size < x && n.IsDir() {
		canClean = n.Size
	}

	for _, child := range n.Children {
		canClean += child.MaxToClean(x)
	}

	return canClean
}

func (n *Node) NeedToCleanFor(wantFree, maxSize int) int {
	y := -1
	mini := int(uint32(y))

	unusedSpace := maxSize
	if n.Name == "/" {
		unusedSpace -= n.Size
	}

	if unusedSpace+n.Size > wantFree && n.IsDir() {
		mini = min(mini, n.Size)
	}

	for _, child := range n.Children {
		mini = min(mini, child.NeedToCleanFor(wantFree, unusedSpace))
	}

	return mini
}

func main() {
	inputb, _ := ioutil.ReadFile("input.txt")
	input := string(inputb)
	root := &Node{
		Name: "",
		Children: map[string]*Node{
			"/": {
				Name:     "/",
				Children: make(map[string]*Node),
				Size:     0,
			},
		},
		Size: 0,
	}
	cwd := make([]string, 0)
	for _, line := range strings.Split(input, "\n") {
		if strings.HasPrefix(line, "$ cd") {
			dir := strings.Split(line, " ")[2]
			switch dir {
			case ".":
				continue
			case "..":
				cwd = cwd[:len(cwd)-1]
			default:
				cwd = append(cwd, dir)
			}
		} else if strings.HasPrefix(line, "$ ls") {
			continue
		} else if strings.HasPrefix(line, "dir") {
			name := strings.Split(line, " ")[1]
			curr := root.MoveTo(cwd)
			curr.Children[name] = &Node{
				Name:     name,
				Children: make(map[string]*Node),
				Size:     0,
			}
		} else {
			parts := strings.Split(line, " ")
			size, err := strconv.Atoi(parts[0])
			if err != nil {
				continue
			}
			name := parts[1]
			curr := root.MoveTo(cwd)
			curr.Children[name] = &Node{
				Name:     name,
				Children: make(map[string]*Node),
				Size:     size,
			}
		}
	}
	root.CalculateSize()

	fmt.Println(root.MaxToClean(100000))
	fmt.Println(root.NeedToCleanFor(30000000, 70000000))
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
