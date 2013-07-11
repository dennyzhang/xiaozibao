package taskgenerator

import (
	"regexp"
	// "fmt"
	)

type Task struct {
	Url string
}

type Stringy func(url string) []Task

func Concat_tasklist(task_list1, task_list2 []Task) []Task {
	newslice := make([]Task, len(task_list1) + len(task_list2))
	copy(newslice, task_list1)
	copy(newslice[len(task_list1):], task_list2)
	return newslice
}

func Filter_tasklist(task_list []Task) []Task {
        return task_list
}

func determinate_generator(url string) Stringy {
	//fmt.Println("determinate_generator:"+ url+ "\n")
        if val, ok := generator[url]; ok {
                return val
        }
        for k, v := range generator {
                if regexp.MustCompile(k).MatchString(url) == true {
                        return v
                }
        }
        return nil
}

func Generate_task(url string) []Task {
	task_generator := determinate_generator(url)
	task_list := task_generator(url)
        return task_list
}
