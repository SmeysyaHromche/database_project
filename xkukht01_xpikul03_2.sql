-- IDS
-- Projekt 2. cast: SQL skript pro vytvoreni objektu schematu databaze
-- Temata: c. 26 'Banka'
-- Autori: Myron Kukhta(xkukht01), Artemii Pikulin(xpikul03)

-- DROP TABLES --  
DROP TABLE AccountStatementsTranscaction;
DROP TABLE TransferTransaction;
DROP TABLE WithdrawalTransaction;
DROP TABLE DepositTransaction;
DROP TABLE AccountStatement;
DROP TABLE BankTransaction;
DROP TABLE ExtendedUser;
DROP TABLE Worker;
DROP TABLE Account;
DROP TABLE AccountOwner;
DROP TABLE Client;

-- ENTITY -- 

-- Tabulka 'Client'
-- Reprezentuje entitu 'Client'.
create table Client(
    ID_Client NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	firstName VARCHAR(20) NOT NULL,
	secondName VARCHAR(20) NOT NULL,
	email VARCHAR(50) NOT NULL
);

-- Tabulka 'AccountOwner'
-- Reprezentuje entitu 'Owner'.
CREATE TABLE AccountOwner(
	ID_AccountOwner INT PRIMARY KEY,
	nationalID VARCHAR(11) NOT NULL,
	telephonNumber VARCHAR(13) NOT NULL,
	dateOfBirthday DATE NOT NULL
);

-- Tabulka 'ExtendedUser'
-- Reprezentuje entitu 'ExtendedUser'.
CREATE TABLE ExtendedUser (
	ID_ExtendedUser INT PRIMARY KEY,
	personGivesAccess INT NOT NULL
);

-- Tabulka 'Worker'
-- Reprezentuje entitu 'Worker'
create table Worker(
	ID_Worker INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	firstName VARCHAR(20) NOT NULL,
	secondName VARCHAR(20) NOT NULL,
	bankBranch VARCHAR(9) NOT NULL,
	workTelephonNumber VARCHAR(13) NOT NULL,
	workEMail VARCHAR(50) NOT NULL
);

-- Tabulka 'Account'
-- Reprezentuje entitu 'Account'
CREATE TABLE Account(
	ID_Account INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	dayLimit NUMBER NOT NULL,
	secretNumber VARCHAR(50) NOT NULL,
	accountOwner INT NOT NULL,
	balance NUMBER DEFAULT 0 NOT NULL,
	currency VARCHAR(3) NOT NULL
);


-- Tabulka 'AccountStatement'
-- Reprezentuje entitu 'AccountStatement'.
CREATE TABLE AccountStatement(
	ID_AccountStatement INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	accountId INT NOT NULL,
	actualDate DATE NOT NULL,
	fromDate DATE NOT NULL,
	toDate DATE NOT NULL,
	requestedOwner INT NOT NULL
);

-- Tabulka 'BankTransaction'
-- Reprezentuje entitu 'Transaction'.
CREATE TABLE BankTransaction(
	ID_Transaction INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	ammount NUMBER NOT NULL,
	transactionDate DATE NOT NULL,
	assignClientId INT NOT NULL,
	executeWorkerId INT NOT NULL,
    approvedState INT NOT NULL
);

-- Tabulka 'TransferTransaction'
-- Reprezentuje entitu 'TransferTransaction'.
CREATE TABLE TransferTransaction(
	ID_TransferTransaction INT PRIMARY KEY,
	transferFrom INT NOT NULL,
	transferTo INT NOT NULL,
    toBankID VARCHAR(7) DEFAULT 'XXX-007' -- ID naseho banku
);

-- Tabulka 'WithdrawalTransaction'
-- Reprezentuje entitu 'WithdrawalTransaction'.
CREATE TABLE WithdrawalTransaction(
	ID_WithdrawalTransaction INT PRIMARY KEY,
	withdrawalFrom INT NOT NULL
);

-- Tabulka 'DepositTransaction'
-- Reprezentuje entitu 'DepositTransaction'.
CREATE TABLE DepositTransaction(
	ID_DepositTransaction INT PRIMARY KEY,
	depositTo INT NOT NULL
);


-- VZTAHY --

-- Tabulka 'AccountStatementsJoinTranscaction'
-- Vestavena tabulka reprezentuje vztah 'describes' mezi entitou 'Account' a 'Transaction'.
CREATE TABLE AccountStatementsTranscaction(
	accountStatementId INT NOT NULL,
	transactionId INT NOT NULL,
	CONSTRAINT PK_AccountStatementsTranscaction PRIMARY KEY (accountStatementId, transactionId),
	CONSTRAINT FK_AccountStateId FOREIGN KEY (accountStatementId) REFERENCES AccountStatement(ID_AccountStatement) ON DELETE CASCADE,
	CONSTRAINT FK_TransactionId FOREIGN KEY (transactionId) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE
);

-- vztah generalizace mezi entitou 'Client' a 'Owner'
ALTER TABLE AccountOwner ADD CONSTRAINT FK_Owner_Client FOREIGN KEY (ID_AccountOwner) REFERENCES Client(ID_Client) ON DELETE CASCADE;

-- vztah generalizace mezi entitou 'Client' a 'ExtendedUser'
ALTER TABLE ExtendedUser ADD CONSTRAINT FK_ExtendedUser_IDExtendedUser FOREIGN KEY (ID_ExtendedUser) REFERENCES Client(ID_Client) ON DELETE CASCADE;

-- vztah 'give access' mezi entitou 'Owner' a 'ExtendedUser'
ALTER TABLE ExtendedUser ADD CONSTRAINT FK_ExtendedUser_PersonGivesAccess FOREIGN KEY (personGivesAccess) REFERENCES AccountOwner(ID_AccountOwner) ON DELETE CASCADE;

-- Popisuhe vztah 'own' mezi entitou 'Owner' a entitou 'Account' 
ALTER TABLE Account ADD CONSTRAINT FK_AccountOwner FOREIGN KEY (accountOwner) REFERENCES AccountOwner(ID_AccountOwner) ON DELETE CASCADE;

-- vztah 'assign' mezi entitou 'Client' a entitou 'Transaction'
ALTER TABLE BankTransaction ADD CONSTRAINT FK_BankTransaction_assignClientId FOREIGN KEY (assignClientId) REFERENCES Client(ID_Client) ON DELETE SET NULL;

-- vztah 'execute' mezi entitou 'Worker' a entitou 'Transaction'
ALTER TABLE BankTransaction ADD	CONSTRAINT FK_BankTransaction_executeWorkerId FOREIGN KEY (executeWorkerId) REFERENCES Worker(ID_Worker) ON DELETE SET NULL;

-- vztah generalizace mezi entitou 'Transaction' a 'WithdrawalTransaction'
ALTER TABLE WithdrawalTransaction ADD CONSTRAINT FK_ID_WithdrawalTransaction FOREIGN KEY (ID_WithdrawalTransaction) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE;

-- vztah generalizace mezi entitou 'Transaction' a 'DepositTransaction'
ALTER TABLE DepositTransaction ADD CONSTRAINT FK_ID_DepositTransaction FOREIGN KEY (ID_DepositTransaction) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE;

-- vztah generalizace mezi entitou 'Transaction' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_ID_TransferTransaction FOREIGN KEY (ID_TransferTransaction) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE;

-- vztah 'transfer from' mezi entitou 'Account' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_TransferTransaction_transferFrom FOREIGN KEY (transferFrom) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'transfer to' mezi entitou 'Account' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_TransferTransaction_transferTo FOREIGN KEY (transferTo) REFERENCES Account(ID_Account) ON DELETE SET NULL;

-- vztah 'withdrawal from' mezi entitou 'Account' a 'WithdrawalTransaction'
ALTER TABLE WithdrawalTransaction ADD CONSTRAINT FK_WithdrawalTransaction_withdrawalFrom FOREIGN KEY (withdrawalFrom) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'deposit to' mezi entitou 'Account' a 'DepositTransaction'
ALTER TABLE DepositTransaction ADD CONSTRAINT FK_DepositTransaction_depositTo FOREIGN KEY (depositTo) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'about' mezi entitou 'Account' a 'AccountStatement'
ALTER TABLE AccountStatement ADD CONSTRAINT FK_AccountStatement_accountId FOREIGN KEY (accountId) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'request' mezi entitou 'Owner' a 'AccountStatement'
ALTER TABLE AccountStatement ADD CONSTRAINT FK_AccountStatement_requestedOwner FOREIGN KEY (requestedOwner) REFERENCES AccountOwner(ID_AccountOwner) ON DELETE SET NULL;


-- KONTROLA --

-- kontrola formatu e-mail entity 'Client' : [libovolna kombinace cislic, literal a '_']@[libovolni pocet str domen][povoleni jen 4 horni domeny com,edu,org,net]
ALTER TABLE Client ADD CONSTRAINT check_Clinet_email CHECK (REGEXP_LIKE(email, '^[a-zA-Z0-9_]+@([a-zA-Z]+.)+[com|edu|org|net]$', 'i'));

-- kontrola formati rodniho cisla entity 'Owner': delka=9/10, [YYYYMMDD/NNN(N)]
ALTER TABLE AccountOwner ADD CONSTRAINT check_AccountOwner_nationalID CHECK (REGEXP_LIKE(nationalID, '^\d{6}/\d{3,4}$'));

-- kontrola formatu telephoniho cisla entity 'Owner' (povoleni jen cesky telefonni cicla): [neni nutno ulozit kod '+420' a neni nutny mezery][NNN NNN NNN]
ALTER TABLE AccountOwner ADD CONSTRAINT check_AccountOwner_telephonNumber CHECK (REGEXP_LIKE(telephonNumber, '^(\+420)?\d{3}\d{3}\d{3}$'));

-- kontrola formatu telephoniho cisla entity 'Worker' (stejne jak pro entitu 'Owner')
ALTER TABLE Worker ADD CONSTRAINT check_Worker_workTelephonNumber CHECK (REGEXP_LIKE(workTelephonNumber, '^(\+420)?\d{3}\d{3}\d{3}$'));

-- kontrola formatu e-mail entity 'Worker'(stejne jak pro entitu 'Client' ale narozdil je staticky horny domeny banku 'bank.com')
ALTER TABLE Worker ADD CONSTRAINT check_Worker_workEMail CHECK (REGEXP_LIKE(workEMail, '^[a-zA-Z0-9_]+@bank.com', 'i'));

-- kontrola formatu pobocky banku pro entity 'Worker': [PSC: NNNNNN]-[tri literaly a tri cisla pro identifikace ulice a cisla domu];
ALTER TABLE Worker ADD CONSTRAINT check_Worker_bankBranch CHECK (REGEXP_LIKE(bankBranch, '^\d{5}-\d{3}'));

-- kontrola formatu meny entity 'Account' (povoleny jen euro, krona a dolar)
ALTER TABLE Account ADD CONSTRAINT check_Account_currency CHECK (REGEXP_LIKE(currency, '^(EUR|USD|CZK)$', 'i'));

-- kontrola formatu identifikace banku pro odchazejici transakce: [tri litery]-[tri cisla]
ALTER TABLE TransferTransaction ADD CONSTRAINT check_TransferTransaction_toBankID CHECK (REGEXP_LIKE(toBankID, '[a-zA-Z]{3}-\d{3}$'));

-- kontrola pseudo_boolean datoveho type
ALTER TABLE BankTransaction ADD CONSTRAINT check_BankTransaction_approvedState CHECK (approvedState IN (0,1));

-- kontrola hodnoty castky transakce
ALTER TABLE BankTransaction ADD CONSTRAINT check_BankTransaction_amount CHECK (ammount > 0);

-- kontrola hodnoty denneho limitu na vyber
ALTER TABLE Account ADD CONSTRAINT check_BankTransaction_dayLimit CHECK (dayLimit >= 0);

-- DATA --

INSERT INTO Worker (firstName, secondName, bankBranch, workTelephonNumber, workEMail)
VALUES ('Jhon', 'Rockefeller', '61200-123', '123123123', 'JhRock@bank.com');

INSERT INTO Worker (firstName, secondName, bankBranch, workTelephonNumber, workEMail)
 VALUES ('Bob', 'Tubik', '61200-123', '+420456456456', 'BTubik@bank.com');

INSERT INTO Client (firstName, secondName, email)
VALUES ('Jhon', 'Snow', 'JSnow@intel.att.com');
INSERT INTO AccountOwner (ID_AccountOwner, nationalID, telephonNumber, dateOfBirthday)
VALUES (1, '010215/1234', '+420775485902', TO_DATE('2001-01-01', 'YYYY-MM-DD'));
INSERT INTO Account (dayLimit, secretNumber, accountOwner, currency)
VALUES (200000, '0000', 1, 'EUR');

INSERT INTO Client (firstName, secondName, email)
VALUES ('Mary', 'Snow', 'YesIAmMarry@gmail.com');
INSERT INTO ExtendedUser (ID_ExtendedUser, personGivesAccess) 
VALUES (2, 1);

INSERT INTO BankTransaction (ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (1000000, TO_DATE('2024-03-20', 'YYYY-MM-DD'), 1, 1, 1);
INSERT INTO DepositTransaction (ID_DepositTransaction, depositTo) 
VALUES(1, 1);

INSERT INTO BankTransaction (ammount, transactionDate, assignClientId, executeWorkerId, approvedState) 
VALUES  (200001, TO_DATE('2024-03-21', 'YYYY-MM-DD'), 2, 2, 0);
INSERT INTO WithdrawalTransaction (ID_WithdrawalTransaction, withdrawalFrom) 
VALUES(2, 1);

INSERT INTO Client (firstName, secondName, email)
VALUES ('Abraham', 'Linkoln', 'LinkolnAndItNotACar@intel.att.com');
INSERT INTO AccountOwner (ID_AccountOwner, nationalID, telephonNumber, dateOfBirthday)
VALUES (3, '770211/9999', '444444444', TO_DATE('2024-07-01', 'YYYY-MM-DD'));
INSERT INTO Account (dayLimit, secretNumber, accountOwner, currency)
VALUES (0.5, '1', 3, 'EUR');


INSERT INTO BankTransaction (ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (200, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 1, 2, 1);
INSERT INTO TransferTransaction (ID_TransferTransaction, transferFrom, transferTo)
VALUES(3, 1, 2);

INSERT INTO AccountStatement (accountId, actualDate, fromDate, toDate, requestedOwner)
VALUES (1, TO_DATE('2024-12-12', 'YYYY-MM-DD'), TO_DATE('2019-03-21', 'YYYY-MM-DD'), TO_DATE('2024-12-12', 'YYYY-MM-DD'), 1);

INSERT INTO AccountStatementsTranscaction (accountStatementId, transactionId)
VALUES (1, 1);
INSERT INTO AccountStatementsTranscaction (accountStatementId, transactionId)
VALUES (1, 2);
INSERT INTO AccountStatementsTranscaction (accountStatementId, transactionId)
VALUES (1, 3);

-- TESTED SELECT BEFORE SENDING NEED DELETE
SELECT * FROM Worker;
SELECT * FROM Client;
SELECT * FROM AccountOwner;
SELECT * FROM Account;
SELECT * FROM ExtendedUser;
SELECT * FROM BankTransaction;
SELECT * FROM DepositTransaction;
SELECT * FROM WithdrawalTransaction;
SELECT * FROM TransferTransaction;
SELECT * FROM AccountStatement;
SELECT * FROM AccountStatementsTranscaction;
