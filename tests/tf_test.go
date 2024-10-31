package test

import (
    "testing"
	"os"
	"log"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestCustomEnvironment(t *testing.T) {
	projectId := os.Getenv("TF_VAR_PROJECT_ID")
	if projectId == "" {
		log.Fatal("You need to set a TF_VAR_PROJECT_ID as an env variable")
	}

	myIPAddress := os.Getenv("TF_VAR_MY_IP_ADDRESS")
	if myIPAddress == "" {
		log.Fatal("You need to set a TF_VAR_MY_IP_ADDRESS as an env variable")
	}

	tfVars := map[string]interface{}{
		"project_id": projectId,
		"my_ip_address": myIPAddress,
	}

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/custom_vpc/",
		Vars: tfVars,
    })

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    output := terraform.Output(t, terraformOptions, "tftest_output")
    assert.Equal(t, "Hello Terratest!", output)
}
