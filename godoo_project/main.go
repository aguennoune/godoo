package main

// go:generate godoo add all --uri http://localhost:8069 --database odoo --username odoo --password odoo16@2023 --output ./api

import (
	"fmt"

	"github.com/llonchj/godoo/api"
)

func main() {
	config := &api.Config{
		DbName:   "odoo",
		Admin:	  "odoo",
		Password: "odoo16@2023",
		URI:	  "http://localhost:8069",
	}

	c, err := config.NewClient()
	if err != nil {
		fmt.Println(err.Error())
	}
	err = c.CompleteSession()
	if err != nil {
		fmt.Println(err.Error())
	}

	// Get the sale order srvice
	s := api.NewSaleOrderService(c)
	// Call the function GetAll() linked to the sale order service
	so, err := s.GetAll()
	if err != nil {
		fmt.Println(err.Error())
	}

	fmt.Println(so)
}

