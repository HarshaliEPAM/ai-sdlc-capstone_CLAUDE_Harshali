Feature: Search Books by Title
  As a bookstore customer
  I want to search for books by entering a title in the search bar
  So that I can quickly find the specific book I want without scrolling the full catalog

  Background:
    Given I am on the bookstore homepage

  @REQ-FR01 @REQ-FR04
  Scenario: Page loads and displays all books
    Then the search input is visible
    And the results grid is visible
    And at least 1 book card is displayed

  @REQ-FR02 @REQ-FR04 @AC-1
  Scenario: Search filters results by title
    When I type "Hobbit" in the search bar
    Then only books with "Hobbit" in the title are displayed

  @REQ-FR04 @AC-2
  Scenario: Each book card shows all required fields
    When I type "Hobbit" in the search bar
    Then the first book card shows a cover image
    And the first book card shows a title
    And the first book card shows an author
    And the first book card shows a price
    And the first book card shows an "Add to Cart" button

  @REQ-FR05 @AC-3
  Scenario: Empty state is shown when no books match the search
    When I type "XYZabc123" in the search bar
    Then the empty state message is displayed
    And the results grid is hidden

  @REQ-FR06 @AC-4
  Scenario Outline: Search is case-insensitive
    When I type "<query>" in the search bar
    Then books matching "hobbit" are displayed

    Examples:
      | query      |
      | the hobbit |
      | THE HOBBIT |
      | The Hobbit |
      | tHe hObBiT |

  @REQ-FR07 @AC-5
  Scenario: Search input enforces 100 character maximum
    When I type a string of 110 characters in the search bar
    Then the search input value is no longer than 100 characters

  @REQ-FR03 @AC-6
  Scenario: Pressing Enter triggers search immediately
    When I type "Harry" in the search bar and press Enter
    Then only books with "Harry" in the title are displayed

  @REQ-FR03
  Scenario: Clicking the search button triggers search
    When I type "1984" in the search bar
    And I click the search button
    Then only books with "1984" in the title are displayed

  @REQ-FR02
  Scenario: Clearing the search input restores all books
    When I type "Hobbit" in the search bar
    And I clear the search input
    Then at least 1 book card is displayed
