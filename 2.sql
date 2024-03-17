-- DROP TABLES -- 

DROP TABLE Client;
DROP TABLE Worker;
DROP TABLE Account;
DROP TABLE AccountStatement;
DROP TABLE BankTransaction;
DROP TABLE AccountStatementJoinTranscaction;
 

-- ENTITY -- 

-- Tabulka 'Client'
-- Reprezentuje entitu 'Client'.
create table Client(
    ID_Client NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	firstName VARCHAR(20) NOT NULL,
	secondName VARCHAR(20) NOT NULL,
	email VARCHAR(50) NOT NULL,
);

-- Tabulka 'AccountOwner'
-- Reprezentuje entitu 'Owner'.
CREATE TABLE AccountOwner(
	ID_AccountOwner NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	nationalID VARCHAR DEFAULT NULL UNIQUE, -- specific value
	telephonNumber VARCHAR(13) DEFAULT NULL,
	dateOfBirthday TIMESTAMP DEFAULT NULL, -- delete address
);

-- Tabulka 'ExtendedUser'
-- Reprezentuje entitu 'ExtendedUser'.
CREATE TABLE ExtendedUser (
	ID_ExtendedUser NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	personGivesAccess NUMBER DEFAULT NULL
);

-- Tabulka 'Worker'
-- Reprezentuje entitu 'Worker'
create table Worker(
	ID_Worker NUMBER GENERATED BY DEFAULT AS IDENTIFIED PRIMARY KEY,
	firstName VARCHAR(20) NOT NULL,
	secondName VARCHAR(20) NOT NULL,
	bankBranch NUMBER NOT NULL, -- specific value
	workTelephonNumber VARCHAR(13) NOT NULL,
	workEMail VARCHAR(50) NOT NULL,
);

-- Tabulka 'Account'
-- Reprezentuje entitu 'Account'
CREATE TABLE Account(
	ID_Account NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	dayLimit NUMBER NOT NULL,
	secretNumber NUMBER NOT NULL, -- specific value
	accountOwner NUMBER NOT NULL,
	balance NUMBER NOT NULL,
	currency VARCHAR(3) NOT NULL,
);


-- Tabulka 'AccountStatement'
-- Reprezentuje entitu 'AccountStatement'.
CREATE TABLE AccountStatement(
	ID_AccountStatement GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	accountId NUMBER NOT NULL,
	actualDate TIMESTAMP NOT NULL,
	fromDate TIMESTAMP NOT NULL,
	toDate TIMESTAMP NOT NULL,
);

-- Tabulka 'BankTransaction'
-- Reprezentuje entitu 'Transaction'.
CREATE TABLE BankTransaction(
	ID_Transaction GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	transactionType VARCHAR NOT NULL,
	ammount VARCHAR(10) NOT NULL,
	transactionDate TIMESTAMP NOT NULL,
	assignClientId NUMBER NOT NULL,
	executeWorkerId NUMBER NOT NULL,
	approvedState BOOLEAN NOT NULL
);

-- Tabulka 'TransferTransaction'
-- Reprezentuje entitu 'TransferTransaction'.
CREATE TABLE TransferTransaction(
	ID_TransferTransaction GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	transferFrom VARCHAR NOT NULL,
	transferTo VARCHAR NOT NULL,
	toBankID VARCHAR NOT NULL DEFAULT 'XXX-007' -- ID naseho banku
);

-- Tabulka 'WithdrawalTransaction'
-- Reprezentuje entitu 'WithdrawalTransaction'.
CREATE TABLE WithdrawalTransaction(
	ID_WithdrawalTransaction GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	withdrawalFrom NUMBER NOT NULL
)

-- Tabulka 'DepositTransaction'
-- Reprezentuje entitu 'DepositTransaction'.
CREATE TABLE DepositTransaction(
	ID_DepositTransaction GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	depositTo NUMBER NOT NULL
);


-- VZTAHY --

-- Tabulka 'AccountStatementJoinTranscaction'
-- Vestavena tabulka reprezentuje vztah 'describes' mezi entitou 'Account' a 'Transaction'.
CREATE TABLE AccountStatementsTranscaction(
	accountStatementId NUMBER NOT NULL,
	transactionId NUMBER NOT NULL,
	CONSTRAINT PK_AccountStatementsTranscaction PRIMARY KEY (accountStatementId, transactionId),
	CONSTRAINT FK_AccountStateId FOREIGN KEY (accountStatementId) REFERENCES AccountStatement(ID_AccountStatement),
	CONSTRAINT FK_TransactionId FOREIGN KEY (transactionId) REFERENCES Transaction(ID_Transaction)
);

-- vztah generalizace mezi entitou 'Client' a 'Owner'
ALTER TABLE AccountOwner ADD CONSTRAINT FK_Owner_Client FOREIGN KEY (ID_Owner) REFERENCES Client(ID_Client);

-- vztah generalizace mezi entitou 'Client' a 'ExtendedUser'
ALTER TABLE ExtendedUser ADD CONSTRAINT FK_ExtendedUser_IDExtendedUser FOREIGN KEY (ID_ExtendedUser) REFERENCES Client(ID_Client);

-- vztah 'give access' mezi entitou 'Owner' a 'ExtendedUser'
ALTER TABLE ExtendedUser ADD CONSTRAINT FK_ExtendedUser_PersonGivesAccess FOREIGN KEY (personGivesAccess) REFERENCES Owner(ID_Owner);

-- Popisuhe vztah 'own' mezi entitou 'Owner' a entitou 'Account' 
ALTER TABLE Account ADD CONSTRAINT FK_AccountOwner FOREIGN KEY (accountOwner) REFERENCES AccountOwner(ID_AccountOwner);

-- vztah 'assign' mezi entitou 'Client' a entitou 'Transaction'
ALTER TABLE BankTransaction ADD CONSTRAINT FK_BankTransaction_assignClientId FOREIGN KEY (assignClientId) REFERENCES Client(ID_Client),

-- vztah 'execute' mezi entitou 'Worker' a entitou 'Transaction'
ALTER TABLE BankTransaction ADD	CONSTRAINT FK_BankTransaction_executeWorkerId FOREIGN KEY (executeWorkerId) REFERENCES Worker(ID_Worker);

-- TODO: are really need ???
-- ALTER TABLE AccountStatement ADD CONSTRAINT FK_AccountStatement_accountId FOREIGN KEY (clientId) REFERENCES Client(ID_Clinet);

-- vztah generalizace mezi entitou 'Transaction' a 'WithdrawalTransaction'
ALTER TABLE WithdrawalTransaction ADD CONSTRAINT FK_ID_WithdrawalTransaction FOREIGN KEY (ID_WithdrawalTransaction) REFERENCES BankTransaction(ID_Transaction);

-- vztah generalizace mezi entitou 'Transaction' a 'DepositTransaction'
ALTER TABLE DepositTransaction ADD CONSTRAINT FK_ID_DepositTransaction FOREIGN KEY (ID_DepositTransaction) REFERENCES BankTransaction(ID_Transaction);

-- vztah generalizace mezi entitou 'Transaction' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_ID_TransferTransaction FOREIGN KEY (ID_TransferTransaction) REFERENCES BankTransaction(ID_Transaction);

-- vztah 'transfer from' mezi entitou 'Account' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_TransferTransaction_transferFrom FOREIGN KEY (transferFrom) REFERENCES Account(ID_Account);

-- vztah 'transfer to' mezi entitou 'Account' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_TransferTransaction_transferTo FOREIGN KEY (transferTo) REFERENCES Account(ID_Account);

-- vztah 'withdrawal from' mezi entitou 'Account' a 'WithdrawalTransaction'
ALTER TABLE WithdrawalTransaction ADD CONSTRAINT FK_WithdrawalTransaction_withdrawalFrom FOREIGN KEY (withdrawalFrom) REFERENCES Account(ID_Account);

-- vztah 'deposit to' mezi entitou 'Account' a 'DepositTransaction'
ALTER TABLE DepositTransaction ADD CONSTRAINT FK_DepositTransaction_depositTo FOREIGN KEY (depositTo) REFERENCES Account(ID_Account);


-- KONTROLA --

-- kontrola formatu e-mail entity 'Client' : [libovolna kombinace cislic, literal a '_']@[libovolni pocet str domen][povoleni jen 4 horni domeny com,edu,org,net]
ALTER TABLE Client ADD CONSTRAINT check_Clinet_email CHECK (REGEX_LIKE(email, '^[a-zA-Z0-9_]+@([a-zA-Z]+.)+[com|edu|org|net]$', 'i'));

-- kontrola formati rodniho cisla entity 'Owner': delka=9/10, [YYYYMMDD/NNN(N)]
ALTER TABLE AccountOwner ADD CONSTRAINT check_AccountOwner_nationalID CHECK (REGEX_LIKE(nationalID, '^\d{6}/\d{3,4}$'));

-- kontrola formatu telephoniho cisla entity 'Owner' (povoleni jen cesky telefonni cicla): [neni nutno ulozit kod '+420' a neni nutny mezery][NNN NNN NNN]
ALTER TABLE AccountOwner ADD CONSTRAINT check_AccountOwner_telephonNumber CHECK (REGEX_LIKE(telephonNumber, '^(\+420\s?)?\d{3}\s?d{3}\s?\d}{3}$'))

-- kontrola ze 'Owner' dospeli
ALTER TABLE AccountOwner ADD CONSTRAINT check_AccountOwner_dateOfBirthday CHECK (MONTH_BETWEEN(SYSDATE, dateOfBirthday)/12 >= 18)

-- kontrola formatu telephoniho cisla entity 'Worker' (stejne jak pro entitu 'Owner')
ALTER TABLE Worker ADD CONSTRAINT check_Worker_workTelephonNumber CHECK (REGEX_LIKE(workTelephonNumber, '^(\+420\s?)?\d{3}\s?d{3}\s?\d}{3}$'))

-- kontrola formatu e-mail entity 'Worker'(stejne jak pro entitu 'Client' ale narozdil je staticky horny domeny banku 'bank.com')
ALTER TABLE Worker ADD CONSTRAINT check_Worker_workEMail CHECK (REGEX_LIKE(workEMail, '^[a-zA-Z0-9_]+@bank.com', 'i'));

-- kontrola formatu pobocky banku pro entity 'Worker': [PSC: NNNNNN]-[tri literaly a tri cisla pro identifikace ulice a cisla domu];
ALTER TABLE Worker ADD CONSTRAINT check_Worker_bankBranch CHECK (REGEX_LIKE(bankBranch, '^\d{5}-\d{3}'));

-- kontrola formatu meny entity 'Account' (povoleny jen euro, krona a dolar)
ALTER TABLE Account ADD CONSTRAINT check_Account_currency CHECK (REGEX_LIKE(currency, '^(EUR|USD|CZK)$', 'i'));

-- kontrola formatu identifikace banku pro odchazejici transakce: [tri litery]-[tri cisla]
ALTER TABLE TransferTransaction ADD CONSTRAINT check_TransferTransaction_toBankID CHECK (REGEX_LIKE(toBankID, '[a-zA-Z]{3}-\d{3}$', 'i'));



-- ULOZENI DAT --

