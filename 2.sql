-- DROP TABLES -- 

DROP TABLE Client;
DROP TABLE Worker;
DROP TABLE Account;
DROP TABLE AccountStatement;
DROP TABLE BankTransaction;
DROP TABLE AccountStatementJoinTranscaction;
 

-- TABLES -- 

-- ----------------------------------------------------------------------------------
-- Tabulka 'Client'
--
-- Reprezentuje zakladnou entitu 'Client', spojenou s 'Owner' a 'ExtendedUser'.
--
-- Popisuje generelzacni vztah mezi entitami pomoci spojeni jejich do spolecne tabulky
-- a zavedeni deskriminantoru 'typ'.
--
-- Speceficky atributy: nationalID, email, telefonNumber . 
-- -----------------------------------------------------------------------------------
create table Client(
    ID_Client NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	firstName VARCHAR(20) NOT NULL,
	secondName VARCHAR(20) NOT NULL,
	email VARCHAR(50) NOT NULL,
	nationalID VARCHAR DEFAULT NULL UNIQUE, -- specific value
	clientType VARCHAR(8) NOT NULL,
	telefonNumber VARCHAR(13) DEFAULT NULL,
	dateOfBirthday TIMESTAMP DEFAULT NULL, -- delete address
	personGivesAccess NUMBER DEFAULT NULL,
);

-- ----------------------------
-- Tabulka 'Worker'
--
-- Reprezentuje entitu 'Worker'
--
-- Specificky atributy : bankBranch, workTelefonNumber, workEMail.
-- ----------------------------
create table Worker(
	ID_Worker NUMBER GENERATED BY DEFAULT AS IDENTIFIED PRIMARY KEY,
	firstName VARCHAR(20) NOT NULL,
	secondName VARCHAR(20) NOT NULL,
	bankBranch NUMBER NOT NULL, -- specific value
	workTelefonNumber VARCHAR(13) NOT NULL,
	workEMail VARCHAR(50) NOT NULL,
);

-- -----------------------------
-- Tabulka 'Account'
--
-- Reprezentuje entitu 'Account'
--
-- Specificky atributy: secretNumber, currency.
-- -----------------------------
CREATE TABLE Account(
	ID_Account NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	dayLimit NUMBER NOT NULL,
	secretNumber NUMBER NOT NULL, -- specific value
	owner NUMBER NOT NULL,
	balance NUMBER NOT NULL,
	currency VARCHAR(3) NOT NULL,
);


-- ------------------------------------------------
-- Tabulka 'AccountStatement'
--
-- Reprezentuje entitu 'AccountStatement'.
-- ------------------------------------------------
CREATE TABLE AccountStatement(
	ID_AccountStatement GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	accountId NUMBER NOT NULL,
	actualDate TIMESTAMP NOT NULL,
	fromDate TIMESTAMP NOT NULL,
	toDate TIMESTAMP NOT NULL,
);

-- -------------------------------------------------
-- Tabulka 'BankTransaction'
--
-- Reprezentuje zakladnou entitu 'Transaction', spojenou s 'TransferTransaction', 'WithdrawalTransaction' a 'DepositeTransaction'
--
-- Popisuje generelzacni vztah mezi entitami pomoci spojeni do spolecne tabulky
-- a zavedeni deskriminatoru 'typ'.
--
-- Speceficky atributy: toBankId.
-- -------------------------------------------------
CREATE TABLE BankTransaction(
	ID_Transaction GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	transactionType VARCHAR NOT NULL,
	ammount VARCHAR(10) NOT NULL,
	transactionDate TIMESTAMP NOT NULL,
	fromAccountId NUMBER DEFAULT NULL,
	toAccountId NUMBER DEFAULT NULL,
	fromBankId VARCHAR DEFAULT 'VF007', -- default our bank id
	toBankId VARCHAR DEFAULT 'VF007',   -- default our bank id
	assignClientId NUMBER NOT NULL,
	executeWorkerId NUMBER NOT NULL,
	approvedState BOOLEAN NOT NULL
);


-- Relationships --

-- ---------------------------------------------
-- Tabulka 'AccountStatementJoinTranscaction'
--
-- Vestavena tabulka reprezentuje vztah 'describes'
-- mezi entitou 'Account' a 'Transaction'.
-- --------------------------------------------- 
CREATE TABLE AccountStatementJoinTranscaction(
	PK_accountStatementId NUMBER NOT NULL,
	PK_transactionId NUMBER NOT NULL,
	CONSTRAINT PK_AccountStatementJoinTransaction PRIMARY KEY (accountStatementId, transactionId),
	CONSTRAINT FK_AccountStateId FOREIGN KEY (accountStatementId) REFERENCES AccountStatement(ID_AccountStatement),
	CONSTRAINT FK_TransactionId FOREIGN KEY (transactionId) REFERENCES Transaction(ID_Transaction)
);

-- Popisuje vztah 'give access' mezi entitou 'Owner' a entitou 'ExtendedUser'
ALTER TABLE Client ADD CONSTRAINT FK_Clinet_personGivesAccess FOREIGN KEY (personGivesAccess) REFERENCES Client(ID_Client);

-- popisuje ztahy:
--                 1) 'assign' mezi entitou 'Client' a entitou 'Transaction'
--                 2) 'execute' mezi entitou 'Worker' a entitou 'Transaction'
ALTER TABLE BankTransaction ADD
	CONSTRAINT FK_BankTransaction_assignClientId FOREIGN KEY (assignClientId) REFERENCES Client(ID_Client),
	CONSTRAINT FK_BankTransaction_executeWorkerId FOREIGN KEY (executeWorkerId) REFERENCES Worker(ID_Worker);

-- TODO: are really need ???
-- ALTER TABLE AccountStatement ADD CONSTRAINT FK_AccountStatement_accountId FOREIGN KEY (clientId) REFERENCES Client(ID_Clinet);

-- Popisuhe vztah 'own' mezi entitou 'Owner' a entitou 'Account' 
ALTER TABLE Account ADD CONSTRAINT FK_AccountOwner FOREIGN KEY (owner) REFERENCES Client(ID_Clinet);

-- Popisuje mezi entotou 'Account' a entitama 'WithdrawalTransaction', 'DepositeTransaction', 'TransferTransaction':
-- vztahy 'deposit to', 'withdrawal from', 'transfer to', 'transfer from' metodou zjednoduseni
ALTER TABLE BankTransaction ADD
	CONSTRAINT FK_BankTransaction_fromAccontID FOREIGN KEY (fromAccountId) REFERENCES Account(ID_Account),
	CONSTRAINT FK_BankTransaction_toAccontID FOREIGN KEY (toAccountId) REFERENCES Account(ID_Account);

-- CHECK --

ALTER TABLE Client ADD 
	CONSTRAINT check_Client_national_id  CHECK (LENGTH(nationalID) = 9),
	CONSTRAINT check_Client_type CHECK clientType = '0wner' OR clientType = 'Extended',
	CONSTRAINT check_Client_mail CHECK 
CONSTRAINT check_Clinet_Types_value CHECK (
	clientType = '0wner' AND (telefonNumber IS NOT NULL AND email IS NOT NULL AND address IS NOT NULL) 
	OR
	clientType = 'Extended' AND (telefonNumber IS NULL AND email IS NULL)
)
