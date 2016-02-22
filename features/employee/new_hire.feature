Feature: New hire

	Scenario: New employee who does not have a pre-existing person
		Given an employer with a published plan year
		And that employer has passed open enrollment
		And I am on the roster as a new employee, with a start date outside of open enrollment
		When I create a new account
		And I match with my roster entry for the employer
		And I complete my personal information
		And I complete my family information
		Then I should be able to shop for plans
		And I should be able to complete plan shopping
