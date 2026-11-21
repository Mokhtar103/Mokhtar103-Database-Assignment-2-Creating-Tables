1 - BidNile is divided into 4 schemas to organize tables according to their business responsibilities and improve maintainability

Accounts ->	City, Member, Wallet -	Manages member information, locations, and financial accounts
Operations -> Warehouse, Employee - Manages warehouses, employees, and warehouse management
Catalogue -> Category, Item, Photo - Manages product listings, categories, specifications, and photos
Auctions ->	Auction, Bid - Manages auctions and bidding activities


2 - Relationship types and how they are mapped

* 1:1:	Member – Wallet -> MemberID is a UNIQUE FK in Wallet
* 1:N:	City – Member -> CityID FK in Member
* M:N:	Member – Auction -> created AuctionFollower with a composite PK (MemberID, AuctionID)
* Recursive: Member – Member -> InvitedByMemberID references MemberID. Also Category has ParentCategoryCode referencing itself
* Circular:	Warehouse – Employee ->	Warehouse.ManagerMemberID references Employee, while Employee.WarehouseID references Warehouse
* Weak entity: Photo – Item -> Photo has its own PhotoID PK and an ItemID FK; deleting an Item cascades to its Photos

3 - Why these data types?

- GUID for Members: Provides globally unique IDs(as in the business case requested for members id), useful for distributed systems

- BIGINT for Bids: Supports a very large number of bids over time (bids are hunders of millions in our business case)

- FLOAT for GPS: GPS coordinates can contain fractional values and need approximate precision 

- DECIMAL for money: Provides exact numbers and avoids floating-point rounding errors

- DATETIMEOFFSET for auctions: Stores date and time with timezone offset, allowing auctions in different countries and time zones (as provided in the business case)

4 - Why can't the circular relationship be created inside CREATE TABLE?

- Because each table references the other, and one table may not exist when SQL Server creates the other

The solution is to create both tables first, then add the foreign keys using ALTER TABLE

5 - Order of filling the tables

1. City: Because it has no dependecies
2. Member: Depends on City and has a self-reference
3. Category: Parent categories must exist before child categories
4. Warehouse: Depends on City, temporarily disable its manager FK
5. Employee: Depends on Member and Warehouse
6. Wallet: Depends on Member
7. Item: Depends on Member, Employee, Category and Warehouse
8. Photo: Depends on Item
9. Auction: Depends on Item
10. Bid: Depends on Auction and Member
11. AuctionFollower: Depends on Auction and Member

6 - Errors in Tasks 3.6 and 3.11

1. Change MaxItems to SMALLINT

- Error: The CHECK constraint depended on MaxItems, preventing the column alteration
- Fix: Dropped the CHECK constraint, altered the column to SMALLINT, then recreated the CHECK constraint

2. Replace IsVerified with VerifiedAt

- Error: The DEFAULT constraint depended on IsVerified, preventing its deletion
- Fix: Added VerifiedAt, dropped the DEFAULT constraint, then dropped IsVerified

7 - Tracing of Task 5 

[1, 2, 3, 4]

First : prefix

start with prefix[0] = 1 because there are no elements before index 0
index 1 -> 1
index 2 -> 2 * 1 = 2
index 3 -> 3 * 2 * 1 = 6

prefix = [1, 1, 2, 6]

Second: Suffix

Start with suffix[n - 1] = 1 because there are no elements after last index (3 in our case)

index 2 -> 4
index 1 -> 3 * 4 = 12
index 0 -> 2 * 3 * 4 = 24

suffix = [24, 12, 4, 1]

now we multiply suffix[] with prefix[]

Final output = [24, 12, 8, 6]


