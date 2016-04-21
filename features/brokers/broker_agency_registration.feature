Feature: On the broker registration page, default should be New Broker Agency

	Scenario: New Broker Agency is the default selected tab.
		When Broker visits the HBX Broker Registration page
		When Broker clicks on Broker Registration tab
		Then the Broker should see New Broker Agency as the active tab