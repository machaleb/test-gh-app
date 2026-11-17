package main

import (
	"fmt"
	"log"

	"github.com/go-git/go-git/v5"
)

func main() {
	fmt.Println("Hello, World!")

	// Use the go-git module to read this repository's remotes.
	repo, err := git.PlainOpen(".")
	if err != nil {
		log.Fatalf("failed to open git repo: %v", err)
	}

	remotes, err := repo.Remotes()
	if err != nil {
		log.Fatalf("failed to list remotes: %v", err)
	}

	for _, r := range remotes {
		fmt.Printf("remote %s: %v\n", r.Config().Name, r.Config().URLs)
	}
}
