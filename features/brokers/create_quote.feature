Feature: Create Employee Roster
  In order for Brokers to give a quote to employees
  The Brosker should be able to add emloyees 
  And Generate a quote

  Scenario: Broker should be able to add employee to employee roster
    Given that a broker exists
    And the broker is signed in
    When he visits the Roster Quoting tool
    And click on the Add New Employee button
    Then a new row should be added to Employee table

   Scenario: Broker should be able to add employees to the employee roster using Upload Employee Roster button
   	Given that a broker exists
   	And the broker is signed in
   	When he visits the Roster Quoting tool
   	And click on the Upload Employee Roster button
   	When the broker clicks on the Select File to Upload button
   	And the broker should see the data in the table


