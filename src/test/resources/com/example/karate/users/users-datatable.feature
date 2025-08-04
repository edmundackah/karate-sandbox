Feature: User Data Table Examples - Multiple test scenarios with parallel execution

Background:
  * url baseUrl
  * path '/api/users'
  * def authHeader = getAuthHeaders()
  * configure headers = karate.merge(defaultHeaders, authHeader)

@users @datatable @parallel
Scenario Outline: Create multiple users with different data
  * def userData = 
    """
    {
      "name": "<name>",
      "email": "<email>",
      "role": "<role>",
      "active": <active>
    }
    """
  Given request userData
  When method POST
  Then status 201
  And match response.name == '<name>'
  And match response.email == '<email>'
  And match response.role == '<role>'
  And match response.active == <active>
  And match response.id == '#number'

  Examples:
    | name          | email                    | role    | active |
    | Alice Cooper  | alice.cooper@example.com | admin   | true   |
    | Bob Wilson    | bob.wilson@example.com   | user    | true   |
    | Carol Brown   | carol.brown@example.com  | user    | false  |
    | David Garcia  | david.garcia@example.com | admin   | true   |
    | Eve Martinez  | eve.martinez@example.com | user    | false  |

@users @datatable @queryparams
Scenario Outline: Query users with different parameters
  Given param role = '<role>'
  And param active = <active>
  When method GET
  Then status 200
  And match response == '#[]'
  # Verify all returned users match the query criteria
  And match each response.role == '<role>'
  And match each response.active == <active>

  Examples:
    | role  | active |
    | admin | true   |
    | user  | true   |
    | user  | false  |

@users @datatable @validation
Scenario Outline: Test user validation with invalid data
  * def invalidUser = 
    """
    {
      "name": "<name>",
      "email": "<email>",
      "role": "<role>",
      "active": <active>
    }
    """
  Given request invalidUser
  When method POST
  Then status <expectedStatus>

  Examples:
    | name  | email           | role    | active | expectedStatus |
    |       | test@email.com  | user    | true   | 400           |
    | Test  |                 | user    | true   | 400           |
    | Test  | invalid-email   | user    | true   | 400           |
    | Test  | test@email.com  |         | true   | 400           |