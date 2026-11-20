-- Task 2 - CREATE

CREATE DATABASE BidNile;
GO

USE BidNile;
GO

CREATE SCHEMA Accounts;
GO

CREATE SCHEMA Operations;
GO

CREATE SCHEMA Catalogue;
GO

CREATE SCHEMA Auctions;
GO

-- Accounts

CREATE TABLE Accounts.City
(
    Id INT IDENTITY(1,1)
        CONSTRAINT PK_City PRIMARY KEY,

    Name NVARCHAR(60) NOT NULL,

    CountryCode CHAR(2) NOT NULL
        CONSTRAINT CK_City_CountryCode
        CHECK (CountryCode IN ('EG', 'SA', 'AE')),

    CONSTRAINT UQ_City_CityName_CountryCode
        UNIQUE (Name, CountryCode)
);
GO


CREATE TABLE Accounts.Member
(
    Id UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_Member_MemberID DEFAULT NEWID(),

    FullName NVARCHAR(100) NOT NULL,

    Email VARCHAR(254) NOT NULL
        CONSTRAINT UQ_Member_Email UNIQUE,

    Mobile VARCHAR(16) NOT NULL,

    NationalID VARCHAR(20) NOT NULL
        CONSTRAINT UQ_Member_NationalID UNIQUE,

    BirthDate DATE NOT NULL,

    IsVerified BIT NOT NULL
        CONSTRAINT DF_Member_IsVerified DEFAULT 0,

    RegisteredAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Member_RegisteredAt DEFAULT SYSDATETIME(),

    CityID INT NOT NULL,

    InvitedByMemberID UNIQUEIDENTIFIER NULL,

    CONSTRAINT PK_Member PRIMARY KEY (Id)
);
GO

CREATE TABLE Accounts.Wallet
(
    Id INT IDENTITY(1,1)
        CONSTRAINT PK_Wallet PRIMARY KEY,

    MemberID UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT UQ_Wallet_MemberID UNIQUE,

    Balance DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Wallet_Balance DEFAULT 0
        CONSTRAINT CK_Wallet_Balance CHECK (Balance >= 0),

    AmountOnHold DECIMAL(12,2) NOT NULL
        CONSTRAINT DF_Wallet_AmountOnHold DEFAULT 0
        CONSTRAINT CK_Wallet_AmountOnHold CHECK (AmountOnHold >= 0),

    Currency CHAR(3) NOT NULL
        CONSTRAINT DF_Wallet_Currency DEFAULT 'EGP',

    LastUpdatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Wallet_LastUpdatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Wallet_AmountOnHold_Balance
        CHECK (AmountOnHold <= Balance)
);
GO

-- Operations

CREATE TABLE Operations.Warehouse
(
    Id INT IDENTITY(1,1)
        CONSTRAINT PK_Warehouse PRIMARY KEY,

    Name NVARCHAR(80) NOT NULL
        CONSTRAINT UQ_Warehouse_WarehouseName UNIQUE,

    Capacity INT NOT NULL
        CONSTRAINT CK_Warehouse_Capacity CHECK (Capacity > 0),

    CityID INT NOT NULL,

    Latitude FLOAT NOT NULL,

    Longitude FLOAT NOT NULL,

    ManagerMemberID UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT UQ_Warehouse_ManagerMemberID UNIQUE,

    ManageStartDate DATE NOT NULL,

    CONSTRAINT CK_Warehouse_Location
        CHECK (
            Latitude BETWEEN -90 AND 90
            AND Longitude BETWEEN -180 AND 180
        )
);
GO

CREATE TABLE Operations.Employee
(
    MemberID UNIQUEIDENTIFIER NOT NULL,

    WarehouseID INT NOT NULL,

    CONSTRAINT PK_Employee PRIMARY KEY (MemberID)
);
GO

-- Catalogue

CREATE TABLE Catalogue.Category
(
    Code INT NOT NULL
        CONSTRAINT PK_Category PRIMARY KEY,

    EnglishName VARCHAR(50) NOT NULL
        CONSTRAINT UQ_Category_EnglishName UNIQUE,

    ArabicName NVARCHAR(50) NULL,

    CommissionRate DECIMAL(4,2) NOT NULL
        CONSTRAINT CK_Category_CommissionRate
        CHECK (CommissionRate BETWEEN 0 AND 30),

    ParentCategoryCode INT NULL
);
GO

CREATE TABLE Catalogue.Item
(
    Id INT IDENTITY(1,1)
        CONSTRAINT PK_Item PRIMARY KEY,

    Title NVARCHAR(150) NOT NULL,

    Description NVARCHAR(MAX) NULL,

    ConditionScore TINYINT NOT NULL
        CONSTRAINT CK_Item_ConditionScore
        CHECK (ConditionScore BETWEEN 1 AND 10),

    Specifications NVARCHAR(MAX) NOT NULL
        CONSTRAINT CK_Item_Specifications_JSON
        CHECK (ISJSON(Specifications) = 1),

    ListedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Item_ListedAt DEFAULT SYSDATETIME(),

    SellerID UNIQUEIDENTIFIER NOT NULL,

    InspectorID UNIQUEIDENTIFIER NULL,

    CategoryCode INT NOT NULL,

    WarehouseID INT NULL,

    CONSTRAINT CK_Item_Seller_Inspector
        CHECK (
            InspectorID IS NULL
            OR SellerID <> InspectorID
        )
);
GO

CREATE TABLE Catalogue.Photo
(
    Id INT IDENTITY(1,1)
        CONSTRAINT PK_Photo PRIMARY KEY,

    ItemID INT NOT NULL,

    Position TINYINT NOT NULL
        CONSTRAINT CK_Photo_Position CHECK (Position BETWEEN 1 AND 20),

    URL VARCHAR(500) NOT NULL,

    IsMain BIT NOT NULL
        CONSTRAINT DF_Photo_IsMain DEFAULT 0,

    CONSTRAINT UQ_Photo_ItemID_Position
        UNIQUE (ItemID, Position)
);
GO

-- Auctions

CREATE TABLE Auctions.Auction
(
    Id INT IDENTITY(1,1)
        CONSTRAINT PK_Auction PRIMARY KEY,

    ItemID INT NOT NULL,

    StartingPrice DECIMAL(19,2) NOT NULL
        CONSTRAINT CK_Auction_StartingPrice
        CHECK (StartingPrice > 0),

    ReservePrice DECIMAL(19,2) NULL,

    BidIncrement DECIMAL(19,2) NOT NULL
        CONSTRAINT DF_Auction_BidIncrement DEFAULT 50.00
        CONSTRAINT CK_Auction_BidIncrement CHECK (BidIncrement > 0),

    StartAt DATETIMEOFFSET NOT NULL,

    EndAt DATETIMEOFFSET NOT NULL,

    Status VARCHAR(10) NOT NULL
        CONSTRAINT DF_Auction_Status DEFAULT 'Draft'
        CONSTRAINT CK_Auction_Status
        CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled')),

    CONSTRAINT CK_Auction_ReservePrice
        CHECK (ReservePrice IS NULL OR ReservePrice >= StartingPrice),

    CONSTRAINT CK_Auction_EndAt
        CHECK (EndAt > StartAt)
);
GO

CREATE TABLE Auctions.Bid
(
    BidID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_Bid PRIMARY KEY,

    AuctionID INT NOT NULL,

    MemberID UNIQUEIDENTIFIER NOT NULL,

    Amount DECIMAL(19,2) NOT NULL
        CONSTRAINT CK_Bid_Amount CHECK (Amount > 0),

    PlacedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_Bid_PlacedAt DEFAULT SYSDATETIME(),

    IPAddress VARCHAR(45) NOT NULL,

    CONSTRAINT UQ_Bid_AuctionID_Amount
        UNIQUE (AuctionID, Amount)
);
GO

CREATE TABLE Auctions.AuctionFollower
(

    MemberID UNIQUEIDENTIFIER NOT NULL,

    AuctionID INT NOT NULL,

    FollowedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_AuctionFollower_FollowedAt DEFAULT SYSDATETIME(),

	CONSTRAINT PK_AuctionFollower
		PRIMARY KEY (MemberID, AuctionID)
);
GO

-- Task 3 - ALTER

-- 3.1 - Member -> City
ALTER TABLE Accounts.Member
WITH CHECK
ADD CONSTRAINT FK_Member_City
FOREIGN KEY (CityID)
REFERENCES Accounts.City(Id)
ON DELETE NO ACTION;
GO

-- 3.1 - Member -> Member
ALTER TABLE Accounts.Member
WITH CHECK
ADD CONSTRAINT FK_Member_InvitedByMember
FOREIGN KEY (InvitedByMemberID)
REFERENCES Accounts.Member(Id)
ON DELETE NO ACTION;
GO

-- 3.1 - Wallet -> Member
ALTER TABLE Accounts.Wallet
WITH CHECK
ADD CONSTRAINT FK_Wallet_Member
FOREIGN KEY (MemberID)
REFERENCES Accounts.Member(Id)
ON DELETE NO ACTION;
GO

-- 3.1 - Warehouse -> City
ALTER TABLE Operations.Warehouse
WITH CHECK
ADD CONSTRAINT FK_Warehouse_City
FOREIGN KEY (CityID)
REFERENCES Accounts.City(Id)
ON DELETE NO ACTION;
GO

-- 3.1 - Warehouse -> Employee (Manager)
ALTER TABLE Operations.Warehouse
WITH CHECK
ADD CONSTRAINT FK_Warehouse_ManagerEmployee
FOREIGN KEY (ManagerMemberID)
REFERENCES Operations.Employee(MemberID)
ON DELETE NO ACTION;
GO

-- 3.1 -  Employee -> Member
ALTER TABLE Operations.Employee
WITH CHECK
ADD CONSTRAINT FK_Employee_Member
FOREIGN KEY (MemberID)
REFERENCES Accounts.Member(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - Employee -> Warehouse
ALTER TABLE Operations.Employee
WITH CHECK
ADD CONSTRAINT FK_Employee_Warehouse
FOREIGN KEY (WarehouseID)
REFERENCES Operations.Warehouse(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - Category -> Category (Parent category)
ALTER TABLE Catalogue.Category
WITH CHECK
ADD CONSTRAINT FK_Category_ParentCategory
FOREIGN KEY (ParentCategoryCode)
REFERENCES Catalogue.Category(Code)
ON DELETE NO ACTION;
GO

-- 3-1 - Item -> Member (Seller)
ALTER TABLE Catalogue.Item
WITH CHECK
ADD CONSTRAINT FK_Item_SellerMember
FOREIGN KEY (SellerID)
REFERENCES Accounts.Member(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - Item -> Employee (Inspector)
ALTER TABLE Catalogue.Item
WITH CHECK
ADD CONSTRAINT FK_Item_InspectorEmployee
FOREIGN KEY (InspectorID)
REFERENCES Operations.Employee(MemberID)
ON DELETE NO ACTION;
GO

-- 3.1 - Item -> Category
ALTER TABLE Catalogue.Item
WITH CHECK
ADD CONSTRAINT FK_Item_Category
FOREIGN KEY (CategoryCode)
REFERENCES Catalogue.Category(Code)
ON DELETE NO ACTION;
GO

-- 3-1 - Item -> Warehouse
ALTER TABLE Catalogue.Item
WITH CHECK
ADD CONSTRAINT FK_Item_Warehouse
FOREIGN KEY (WarehouseID)
REFERENCES Operations.Warehouse(Id)
ON DELETE NO ACTION;
GO

-- 3.1 - Photo -> Item
ALTER TABLE Catalogue.Photo
WITH CHECK
ADD CONSTRAINT FK_Photo_Item
FOREIGN KEY (ItemID)
REFERENCES Catalogue.Item(Id)
ON DELETE CASCADE;
GO

-- 3-1 - Auction -> Item
ALTER TABLE Auctions.Auction
WITH CHECK
ADD CONSTRAINT FK_Auction_Item
FOREIGN KEY (ItemID)
REFERENCES Catalogue.Item(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - Bid -> Auction
ALTER TABLE Auctions.Bid
WITH CHECK
ADD CONSTRAINT FK_Bid_Auction
FOREIGN KEY (AuctionID)
REFERENCES Auctions.Auction(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - Bid -> Member
ALTER TABLE Auctions.Bid
WITH CHECK
ADD CONSTRAINT FK_Bid_Member
FOREIGN KEY (MemberID)
REFERENCES Accounts.Member(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - AuctionFollower -> Member
ALTER TABLE Auctions.AuctionFollower
WITH CHECK
ADD CONSTRAINT FK_AuctionFollower_Member
FOREIGN KEY (MemberID)
REFERENCES Accounts.Member(Id)
ON DELETE NO ACTION;
GO

-- 3-1 - AuctionFollower -> Auction
ALTER TABLE Auctions.AuctionFollower
WITH CHECK
ADD CONSTRAINT FK_AuctionFollower_Auction
FOREIGN KEY (AuctionID)
REFERENCES Auctions.Auction(Id)
ON DELETE NO ACTION;
GO

-- 3.2 
ALTER TABLE Accounts.Member
ADD PreferredLanguage VARCHAR(2) NOT NULL
    CONSTRAINT DF_Member_PreferredLanguage DEFAULT 'ar'
    CONSTRAINT CK_Member_PreferredLanguage
        CHECK (PreferredLanguage IN ('ar', 'en'));
GO

-- 3.3
ALTER TABLE Catalogue.Item
ADD IsFeatured BIT NOT NULL
	CONSTRAINT DF_Item_IsFeatured DEFAULT 0;
GO

-- 3.4 - Rename Bid.IPAddress to DeviceIp
EXEC sp_rename
    'Auctions.Bid.IPAddress',
    'DeviceIp',
    'COLUMN';
GO

-- 3.4 - Rename Warehouse.Capacity to MaxItems
ALTER TABLE Operations.Warehouse
DROP CONSTRAINT CK_Warehouse_Capacity;
GO

EXEC sp_rename
    'Operations.Warehouse.Capacity',
    'MaxItems',
    'COLUMN';
GO

ALTER TABLE Operations.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
GO

-- 3.5
ALTER TABLE Accounts.Member
ALTER COLUMN FullName NVARCHAR(150) NOT NULL;
GO

-- 3.6
ALTER TABLE Operations.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL; -- Rejected because of check constraint

ALTER TABLE Operations.Warehouse
DROP CONSTRAINT CK_Warehouse_MaxItems;
GO

ALTER TABLE Operations.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL;
GO

ALTER TABLE Operations.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
GO

-- 3.7
ALTER TABLE Catalogue.Category
DROP CONSTRAINT CK_Category_CommissionRate;
GO

ALTER TABLE Catalogue.Category
ADD CONSTRAINT CK_Category_CommissionRate
CHECK (CommissionRate BETWEEN 0 AND 25);
GO

-- 3.8

-- Replace the CHECK constraint
ALTER TABLE Auctions.Auction
DROP CONSTRAINT CK_Auction_Status;
GO

ALTER TABLE Auctions.Auction
ADD CONSTRAINT CK_Auction_Status
CHECK (Status IN ('Draft', 'PendingReview', 'Live', 'Ended', 'Cancelled'));
GO

-- Replace the DEFAULT constraint
ALTER TABLE Auctions.Auction
DROP CONSTRAINT DF_Auction_Status;
GO

ALTER TABLE Auctions.Auction
ADD CONSTRAINT DF_Auction_Status
DEFAULT 'PendingReview' FOR Status;
GO

-- 3.9
ALTER TABLE Auctions.Auction
ADD BuyNowPrice DECIMAL(19,2) NULL;
GO

ALTER TABLE Auctions.Auction
WITH CHECK
ADD CONSTRAINT CK_Auction_BuyNowPrice
CHECK (
    BuyNowPrice IS NULL
    OR BuyNowPrice > StartingPrice
);
GO

-- 3.10
ALTER TABLE Accounts.Member
	ADD CONSTRAINT UQ_Member_Mobile
	UNIQUE(Mobile)
GO

-- 3.11
ALTER TABLE Accounts.Member
ADD VerifiedAt DATETIME2(3) NULL;
GO

ALTER TABLE Accounts.Member
DROP CONSTRAINT DF_Member_IsVerified;
GO

ALTER TABLE Accounts.Member
DROP COLUMN IsVerified;
GO

-- 3.12
CREATE SCHEMA Marketing
GO

ALTER SCHEMA Marketing
	TRANSFER Auctions.AuctionFollower
GO