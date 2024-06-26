-- IDS
-- Projekt 4. cast: SQL skript pro vytvoreni prokorcilich objektu schematu databaze
-- Temata: c. 26 'Banka'
-- Autori: Myron Kukhta(xkukht01), Artemii Pikulin(xpikul03)

-- DROP TABLES -- 
DROP INDEX executeWorkerId_index;
DROP MATERIALIZED VIEW search_not_approved_transaction;
DROP PROCEDURE create_new_deposit;
DROP PROCEDURE create_new_withdrawal;
DROP PROCEDURE create_new_transfer;
DROP PROCEDURE check_clients_access_right;
DROP PROCEDURE check_day_limit;
DROP PROCEDURE req_acc_statement;
DROP TRIGGER trigger_transfer;
DROP TRIGGER trigger_withdrawal;
DROP TRIGGER trigger_deposite;
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
ALTER TABLE BankTransaction ADD CONSTRAINT FK_BankTransaction_assignClientId FOREIGN KEY (assignClientId) REFERENCES Client(ID_Client) ON DELETE CASCADE;

-- vztah 'execute' mezi entitou 'Worker' a entitou 'Transaction'
ALTER TABLE BankTransaction ADD	CONSTRAINT FK_BankTransaction_executeWorkerId FOREIGN KEY (executeWorkerId) REFERENCES Worker(ID_Worker) ON DELETE CASCADE;

-- vztah generalizace mezi entitou 'Transaction' a 'WithdrawalTransaction'
ALTER TABLE WithdrawalTransaction ADD CONSTRAINT FK_ID_WithdrawalTransaction FOREIGN KEY (ID_WithdrawalTransaction) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE;

-- vztah generalizace mezi entitou 'Transaction' a 'DepositTransaction'
ALTER TABLE DepositTransaction ADD CONSTRAINT FK_ID_DepositTransaction FOREIGN KEY (ID_DepositTransaction) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE;

-- vztah generalizace mezi entitou 'Transaction' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_ID_TransferTransaction FOREIGN KEY (ID_TransferTransaction) REFERENCES BankTransaction(ID_Transaction) ON DELETE CASCADE;

-- vztah 'transfer from' mezi entitou 'Account' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_TransferTransaction_transferFrom FOREIGN KEY (transferFrom) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'transfer to' mezi entitou 'Account' a 'TransferTransaction'
ALTER TABLE TransferTransaction ADD CONSTRAINT FK_TransferTransaction_transferTo FOREIGN KEY (transferTo) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'withdrawal from' mezi entitou 'Account' a 'WithdrawalTransaction'
ALTER TABLE WithdrawalTransaction ADD CONSTRAINT FK_WithdrawalTransaction_withdrawalFrom FOREIGN KEY (withdrawalFrom) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'deposit to' mezi entitou 'Account' a 'DepositTransaction'
ALTER TABLE DepositTransaction ADD CONSTRAINT FK_DepositTransaction_depositTo FOREIGN KEY (depositTo) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'about' mezi entitou 'Account' a 'AccountStatement'
ALTER TABLE AccountStatement ADD CONSTRAINT FK_AccountStatement_accountId FOREIGN KEY (accountId) REFERENCES Account(ID_Account) ON DELETE CASCADE;

-- vztah 'request' mezi entitou 'Owner' a 'AccountStatement'
ALTER TABLE AccountStatement ADD CONSTRAINT FK_AccountStatement_requestedOwner FOREIGN KEY (requestedOwner) REFERENCES AccountOwner(ID_AccountOwner) ON DELETE CASCADE;


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

INSERT INTO Client (firstName, secondName, email)
VALUES ('Abraham', 'Linkoln', 'LinkolnAndItNotACar@intel.att.com');
INSERT INTO AccountOwner (ID_AccountOwner, nationalID, telephonNumber, dateOfBirthday)
VALUES (3, '770211/9999', '444444444', TO_DATE('2024-07-01', 'YYYY-MM-DD'));
INSERT INTO Account (dayLimit, secretNumber, accountOwner, balance, currency)
VALUES (0.5, '1', 3, 100, 'EUR');
INSERT INTO Client (firstName, secondName, email)
VALUES ('Jo', 'Washington', 'JW@gmail.com');
INSERT INTO ExtendedUser (ID_ExtendedUser, personGivesAccess) 
VALUES (4, 3);



INSERT INTO Client (firstName, secondName, email)
VALUES ('Myron', 'Kukhta', 'MyMail@gmail.com');
INSERT INTO AccountOwner (ID_AccountOwner, nationalID, telephonNumber, dateOfBirthday)
VALUES (5, '111111/1111', '123456789', TO_DATE('2002-04-21', 'YYYY-MM-DD'));
INSERT INTO Account (dayLimit, secretNumber, accountOwner, currency, balance)
VALUES (10000, '9999', 5, 'USD', 1000);


-- ADVENCED OBJECTS --

-- TRIGGERS --

-- over podminek a provedeni tranzakce typu WITHDRAWAL --
CREATE OR REPLACE TRIGGER trigger_withdrawal
BEFORE INSERT ON WithdrawalTransaction
FOR EACH ROW
DECLARE
	tr_ammount NUMBER;
	old_balance NUMBER;
BEGIN
	SELECT ammount INTO tr_ammount FROM BankTransaction WHERE :NEW.ID_WithdrawalTransaction = ID_Transaction;
	SELECT balance INTO old_balance FROM Account WHERE :NEW.withdrawalFrom = ID_Account;
	IF old_balance < tr_ammount THEN
		RAISE_APPLICATION_ERROR(-20001, 'Warning! There are not enough funds in the account to complete the transaction');
	END IF;
	UPDATE Account SET balance = balance - tr_ammount WHERE ID_Account = :NEW.withdrawalFrom;
END;
/

-- provedeni tranzakce typu DEPOSIT --
CREATE OR REPLACE TRIGGER trigger_deposite
AFTER INSERT ON DepositTransaction
FOR EACH ROW
DECLARE
	tr_ammount NUMBER;
BEGIN
	SELECT ammount INTO tr_ammount FROM BankTransaction WHERE :NEW.ID_DepositTransaction = ID_Transaction;
	UPDATE Account SET balance = balance + tr_ammount WHERE ID_Account = :NEW.depositTo;
END;
/


-- provedeni tranzakce typu TRANSFER --
CREATE OR REPLACE TRIGGER trigger_transfer
BEFORE INSERT ON TransferTransaction
FOR EACH ROW
DECLARE
	from_currency VARCHAR(3);
	to_currency VARCHAR(3);
	tr_ammount NUMBER;
	from_balance NUMBER;
	old_balance NUMBER;
BEGIN
	IF :NEW.toBankID = 'XXX-007' THEN
			IF :NEW.transferFrom = :NEW.transferTo THEN			
				RAISE_APPLICATION_ERROR(-20002, 'Warning! In the transfer accounts should be not the same.');
			END IF;
			SELECT currency INTO from_currency FROM Account WHERE :NEW.transferFrom = ID_Account;
			SELECT currency INTO to_currency FROM Account WHERE :NEW.transferTo = ID_Account;
			IF from_currency <> to_currency THEN			
				RAISE_APPLICATION_ERROR(-20003, 'Warning! Transaction only between account with the same currency.');
			END IF;
	END IF;
	SELECT ammount INTO tr_ammount FROM BankTransaction WHERE :NEW.ID_TransferTransaction = ID_Transaction;
	SELECT balance INTO old_balance FROM Account WHERE :NEW.transferFrom = ID_Account;
	IF old_balance < tr_ammount THEN
		RAISE_APPLICATION_ERROR(-20001, 'Warning! There are not enough funds in the account to complete the transaction');
	END IF;
	UPDATE Account SET balance = balance - tr_ammount WHERE ID_Account = :NEW.transferFrom;
	IF :NEW.toBankID = 'XXX-007' THEN
		UPDATE Account SET balance = balance + tr_ammount WHERE ID_Account = :NEW.transferTo;
	END IF;
END;
/

-- TEST NA  TRIGGERY

-- test new deposit
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (1, 1, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 4, 2, 1);
INSERT INTO DepositTransaction (ID_DepositTransaction, depositTo)
VALUES(1, 2);

INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (2, 200, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 1, 2, 1);
INSERT INTO DepositTransaction (ID_DepositTransaction, depositTo)
VALUES(2, 1);

-- test bad transfer with the same accounts
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (3, 10000000000000, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 1, 2, 1);
INSERT INTO TransferTransaction (ID_TransferTransaction, transferFrom, transferTo)
VALUES(3, 2, 2);
DELETE FROM BankTransaction WHERE ID_Transaction = 3;

-- test bad transfer with currency
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (3, 100, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 4, 2, 1);
INSERT INTO TransferTransaction (ID_TransferTransaction, transferFrom, transferTo)
VALUES(3, 3, 1);
DELETE FROM BankTransaction WHERE ID_Transaction = 3;

--test bad transfer with ammount
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (3, 10000000, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 1, 2, 1);
INSERT INTO TransferTransaction (ID_TransferTransaction, transferFrom, transferTo)
VALUES(3, 1, 2);
DELETE FROM BankTransaction WHERE ID_Transaction = 3;

-- test correct transfer
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (3, 10, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 1, 2, 1);
INSERT INTO TransferTransaction (ID_TransferTransaction, transferFrom, transferTo)
VALUES(3, 1, 2);

-- test incorrect withdrawal
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (4, 1000000000, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 4, 2, 1);
INSERT INTO WithdrawalTransaction (ID_WithdrawalTransaction, withdrawalFrom)
VALUES(4, 3);
DELETE FROM BankTransaction WHERE ID_Transaction = 4;

-- test correct withdrawal
INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
VALUES  (4, 1, TO_DATE('2024-09-01', 'YYYY-MM-DD'), 4, 2, 1);
INSERT INTO WithdrawalTransaction (ID_WithdrawalTransaction, withdrawalFrom)
VALUES(4, 3);

SELECT * FROM Account;
SELECT * FROM BankTransaction;
SELECT * FROM DepositTransaction;
SELECT * FROM WithdrawalTransaction;
SELECT * FROM TransferTransaction;

-- PROCEDURE --

-- KONTROLA PRISTUPOVYCH PRAV CLIENTA K UCTU --
CREATE OR REPLACE PROCEDURE check_clients_access_right(
	ch_id_client IN Account.accountOwner%TYPE,
	ch_id_account IN Account.ID_Account%TYPE,
	only_for_owner INT) AS
	access NUMBER;
	err_msg VARCHAR(200);
BEGIN
	SELECT COUNT(*) INTO access FROM Account WHERE ID_Account = ch_id_account AND accountOwner=ch_id_client;
	IF access = 0 THEN
		IF only_for_owner = 0 THEN
			-- kontrola ze client ma poskytovany pristup k uctu
			SELECT COUNT(*) INTO access FROM AccountOwner, Account, ExtendedUser WHERE ch_id_client = ExtendedUser.ID_ExtendedUser AND ExtendedUser.personGivesAccess = AccountOwner.ID_AccountOwner AND AccountOwner.ID_AccountOwner = Account.AccountOwner AND Account.ID_Account = ch_id_account;
			IF access = 0 THEN
				err_msg := 'Warning! Client id=' || ch_id_client ||' doesnt have access to manipulation with account id=' || ch_id_account;
				RAISE_APPLICATION_ERROR(-20005, err_msg);
			END IF;
		ELSE 
			err_msg := 'Warning! Client id=' || ch_id_client ||' doesnt have access to manipulation with account id=' || ch_id_account;
			RAISE_APPLICATION_ERROR(-20005, err_msg);
		END IF;
	END IF;
END;
/

-- KONTROLA DENNIHO LIMITU --
CREATE OR REPLACE PROCEDURE check_day_limit(
	id_acc IN Account.ID_Account%TYPE,
	date_tr IN BankTransaction.transactionDate%TYPE,
	new_ammount IN BankTransaction.ammount%TYPE) AS
	all_outgoing NUMBER;
	lim NUMBER;
	trg NUMBER;
	err_msg VARCHAR(200);
BEGIN
	-- denni limit pro ucet
	SELECT dayLimit INTO lim FROM Account WHERE Account.ID_Account = id_acc;
	-- spocitame vse transakce za ten den
	SELECT SUM(ammount) INTO trg FROM BankTransaction, WithdrawalTransaction WHERE BankTransaction.ID_Transaction = WithdrawalTransaction.ID_WithdrawalTransaction AND BankTransaction.transactionDate = date_tr AND WithdrawalTransaction.withdrawalFrom = id_acc;
	IF trg IS NULL THEN
		all_outgoing :=  0;
	END If;
	SELECT SUM(ammount) INTO trg FROM BankTransaction, TransferTransaction WHERE BankTransaction.ID_Transaction = TransferTransaction.ID_TransferTransaction AND BankTransaction.transactionDate = date_tr AND TransferTransaction.transferFrom = id_acc;
	IF trg IS NULL THEN
		all_outgoing :=  all_outgoing + new_ammount;
	ELSE
		all_outgoing := all_outgoing + trg + new_ammount;
	END If;
	-- kontrola
	IF all_outgoing >= lim THEN
		err_msg := 'Warning! New ammount ' || new_ammount || ' exceeds the daily limit on ' || lim || ' for account with id ' || id_acc;
		RAISE_APPLICATION_ERROR(-20005, err_msg);
	END IF;
	
END;
/


-- REQUEST NA NOVY ACCOUNTSTATEMENT --
CREATE OR REPLACE PROCEDURE req_acc_statement(
	newAccountID IN AccountStatement.accountId%TYPE,
	newAtualDate IN AccountStatement.actualDate%TYPE,
	newFromDate IN AccountStatement.fromDate%TYPE,
	newToDate IN AccountStatement.toDate%TYPE,
	newRequestedOwner IN AccountStatement.requestedOwner%TYPE)AS

	-- cursor pro hledani TRANSFERTRANSACTION
	CURSOR search_cursor_transfer IS
	SELECT ID_Transaction FROM BankTransaction, TransferTransaction , Account
	WHERE BankTransaction.ID_Transaction = TransferTransaction.ID_TransferTransaction
	AND (BankTransaction.transactionDate >= newFromDate OR BankTransaction.transactionDate <= newToDate)
	AND TransferTransaction.transferFrom = Account.ID_Account AND Account.accountOwner = newRequestedOwner;
	
	-- cursor pro hledani DEPOSITTRANSACTION
	CURSOR search_cursor_deposit IS
	SELECT ID_Transaction FROM BankTransaction, DepositTransaction , Account
	WHERE BankTransaction.ID_Transaction = DepositTransaction.ID_DepositTransaction
	AND (BankTransaction.transactionDate >= newFromDate OR BankTransaction.transactionDate <= newToDate)
	AND DepositTransaction.depositTo = Account.ID_Account AND Account.accountOwner = newRequestedOwner;

	-- cursor pro hledani WITHDRAWALTRANSACTION
	CURSOR search_cursor_withdrawal IS
	SELECT ID_Transaction FROM BankTransaction, WithdrawalTransaction , Account
	WHERE BankTransaction.ID_Transaction = WithdrawalTransaction.ID_WithdrawalTransaction
	AND (BankTransaction.transactionDate >= newFromDate OR BankTransaction.transactionDate <= newToDate)
	AND WithdrawalTransaction.withdrawalFrom = Account.ID_Account AND Account.accountOwner = newRequestedOwner; 
	
	newID AccountStatement.ID_AccountStatement%TYPE;
	trID BankTransaction.ID_Transaction%TYPE;
BEGIN
	-- pokud klient ma pravo pro prace s uctem
	check_clients_access_right(newRequestedOwner, newAccountID, 1);
	-- vytvareni noveho id
	SELECT MAX(ID_Client) INTO newID FROM Client;
	IF newID IS NULL THEN
		newID := 0;
	ELSE
		newID := newID + 1;
	END IF;

	-- vyrvareni noveho ACCOUNTSTATEMENT
	INSERT INTO  AccountStatement(ID_AccountStatement, accountId, actualDate, fromDate, toDate, requestedOwner)
	VALUES (newID, newAccountID, newAtualDate, newFromDate, newToDate, newRequestedOwner);
	-- hledani tranzakce mezi TRANSFERTRANSACTION
	OPEN search_cursor_transfer;
	LOOP 
		FETCH search_cursor_transfer INTO trID;
		EXIT WHEN search_cursor_transfer%NOTFOUND;
		INSERT INTO AccountStatementsTranscaction(accountStatementId, transactionId)
		VALUES (newID, trID);
	END LOOP;
	CLOSE search_cursor_transfer;
	-- hledani tranzakce mezi DEPOSITTRANSACTION
	OPEN search_cursor_deposit;
	LOOP 
		FETCH search_cursor_deposit INTO trID;
		EXIT WHEN search_cursor_deposit%NOTFOUND;
		INSERT INTO AccountStatementsTranscaction(accountStatementId, transactionId)
		VALUES (newID, trID);
	END LOOP;
	CLOSE search_cursor_deposit;
	-- hledani tranzakce mezi WITHDRAWALTRANSACTION
	OPEN search_cursor_withdrawal;
	LOOP 
		FETCH search_cursor_withdrawal INTO trID;
		EXIT WHEN search_cursor_withdrawal%NOTFOUND;
		INSERT INTO AccountStatementsTranscaction(accountStatementId, transactionId)
		VALUES (newID, trID);
	END LOOP;
	CLOSE search_cursor_withdrawal;
END;
/

-- VYTVARENI NOVE DEPOSITTRANSACTION --
CREATE OR REPLACE PROCEDURE create_new_deposit(
	newAmmount IN BankTransaction.ammount%TYPE,
	newTransactionDate IN BankTransaction.transactionDate%TYPE,
	newAssignClientId IN BankTransaction.assignClientId%TYPE,
	newExecuteWorkerId IN BankTransaction.executeWorkerId%TYPE,
    newApprovedState IN BankTransaction.approvedState%TYPE,
	newDepositTo IN DepositTransaction.depositTo%TYPE) AS
	newID ExtendedUser.ID_ExtendedUser%TYPE;
BEGIN
	-- pokud klient ma pravo pro prace s uctem
	check_clients_access_right(newAssignClientId, newDepositTo, 0);
	-- vytvareni noveho id
	SELECT MAX(ID_Transaction) INTO newID FROM BankTransaction;
	IF newID IS NULL THEN
		newID := 0;
	ELSE
		newID := newID + 1;
	END IF;
	-- ukladani dat
	INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
	VALUES (newID, newAmmount, newTransactionDate, newAssignClientId, newExecuteWorkerId, newApprovedState);
	INSERT INTO DepositTransaction(ID_DepositTransaction, depositTo)
	VALUES (newID, newDepositTo);
EXCEPTION
	WHEN others THEN
		IF sqlcode=-20005 THEN
			DBMS_OUTPUT.PUT_LINE('User id=' || newAssignClientId || 'is not have permission to account id=' || newDepositTo);
	END IF;
END;
/

-- VYTVARENI NOVE WITHDRAWALTRANSACTION --
CREATE OR REPLACE PROCEDURE create_new_withdrawal(
	newAmmount IN BankTransaction.ammount%TYPE,
	newTransactionDate IN BankTransaction.transactionDate%TYPE,
	newAssignClientId IN BankTransaction.assignClientId%TYPE,
	newExecuteWorkerId IN BankTransaction.executeWorkerId%TYPE,
    newApprovedState IN BankTransaction.approvedState%TYPE,
	newWithdrawalFrom IN WithdrawalTransaction.withdrawalFrom%TYPE) AS
	newID ExtendedUser.ID_ExtendedUser%TYPE;
BEGIN
	-- pokud klient ma pravo pro prace s uctem
	check_clients_access_right(newAssignClientId, newWithdrawalFrom, 0);
	-- kontrola limitu
	check_day_limit(newWithdrawalFrom, newTransactionDate, newAmmount);
	-- vytvareni noveho id
	SELECT MAX(ID_Transaction) INTO newID FROM BankTransaction;
	IF newID IS NULL THEN
		newID := 0;
	ELSE
		newID := newID + 1;
	END IF;
	-- ukladani dat
	INSERT INTO BankTransaction (ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
	VALUES (newID, newAmmount, newTransactionDate, newAssignClientId, newExecuteWorkerId, newApprovedState);
	INSERT INTO WithdrawalTransaction(ID_WithdrawalTransaction, withdrawalFrom)
	VALUES (newID, newWithdrawalFrom);
END;
/


-- VYTVARENI NOVE TRANSFERTRANSACTION --
CREATE OR REPLACE PROCEDURE create_new_transfer(
	newAmmount IN BankTransaction.ammount%TYPE,
	newTransactionDate IN BankTransaction.transactionDate%TYPE,
	newAssignClientId IN BankTransaction.assignClientId%TYPE,
	newExecuteWorkerId IN BankTransaction.executeWorkerId%TYPE,
    newApprovedState IN BankTransaction.approvedState%TYPE,
	newTransferFrom IN TransferTransaction.transferFrom%TYPE,
	newTransferTo IN TransferTransaction.transferTo%TYPE,
    newToBankID IN TransferTransaction.toBankID%TYPE) AS
	newID ExtendedUser.ID_ExtendedUser%TYPE;
	checkAllBalance Account.balance%TYPE;
BEGIN
	-- pokud klient ma pravo pro prace s uctem
	check_clients_access_right(newAssignClientId, newTransferFrom, 0);
	-- kontrola limitu
	check_day_limit(newTransferFrom, newTransactionDate, newAmmount);
	-- vytvareni noveho id
	SELECT MAX(ID_Transaction) INTO newID FROM BankTransaction;
	IF newID IS NULL THEN
		newID := 0;
	ELSE
		newID := newID + 1;
	END IF;
	-- ukldadani dat
	INSERT INTO BankTransaction(ID_Transaction, ammount, transactionDate, assignClientId, executeWorkerId, approvedState)
	VALUES (newID, newAmmount, newTransactionDate, newAssignClientId, newExecuteWorkerId, newApprovedState);
	INSERT INTO TransferTransaction(ID_TransferTransaction, transferFrom, transferTo, toBankID)
	VALUES (newID, newTransferFrom, newTransferTo, newToBankID);
END;
/

-- TEST NA PROCEDURY --
-- test check_clients_access_right s cizim uctem pro novy deposit 
BEGIN
	create_new_deposit(1000, TO_DATE('2024-04-26', 'YYYY-MM-DD'), 5, 2, 1, 2);
END;
/
--test create_new_deposit
BEGIN
	create_new_deposit(1000, TO_DATE('2024-04-26', 'YYYY-MM-DD'), 5, 2, 1, 3);
END;
/

-- test na check_day_limit s prkrocennim denniho limitu pro novy withdrawal
BEGIN
	create_new_withdrawal(100000, TO_DATE('2024-04-26', 'YYYY-MM-DD'), 5, 2, 1, 3);
END;
/
-- test create_new_withdrawal
BEGIN
	create_new_withdrawal(500, TO_DATE('2024-04-26', 'YYYY-MM-DD'), 5, 2, 1, 3);
END;
/
-- test create_new_transfer
BEGIN
	create_new_transfer(10, TO_DATE('2024-04-26', 'YYYY-MM-DD'), 2, 2, 1, 1, 2, 'XXX-007');
END;
/
-- test na over ze jen majitel uctu muze pozadat stav
BEGIN
	req_acc_statement(1, TO_DATE('2024-04-26', 'YYYY-MM-DD'), TO_DATE('2024-08-26', 'YYYY-MM-DD'), TO_DATE('2024-09-26', 'YYYY-MM-DD'), 2);
END;
/
-- test req_acc_statement
BEGIN
	req_acc_statement(1, TO_DATE('2024-04-26', 'YYYY-MM-DD'), TO_DATE('2024-08-26', 'YYYY-MM-DD'), TO_DATE('2024-09-26', 'YYYY-MM-DD'), 1);
END;
/

-- PRISTUPOVI PRAVA -- 
GRANT ALL ON AccountStatementsTranscaction TO xpikul03;
GRANT ALL ON TransferTransaction TO xpikul03;
GRANT ALL ON WithdrawalTransaction TO xpikul03;
GRANT ALL ON DepositTransaction TO xpikul03;
GRANT ALL ON AccountStatement TO xpikul03;
GRANT ALL ON BankTransaction TO xpikul03;
GRANT ALL ON ExtendedUser TO xpikul03;
GRANT ALL ON Worker TO xpikul03;
GRANT ALL ON Account TO xpikul03;
GRANT ALL ON AccountOwner TO xpikul03;
GRANT ALL ON Client TO xpikul03;

GRANT EXECUTE ON check_day_limit TO xpikul03;
GRANT EXECUTE ON check_clients_access_right TO xpikul03;
GRANT EXECUTE ON req_acc_statement TO xpikul03;
GRANT EXECUTE ON create_new_deposit TO xpikul03;
GRANT EXECUTE ON create_new_withdrawal TO xpikul03;
GRANT EXECUTE ON create_new_transfer TO xpikul03;

-- priklad nepovolene transakce

-- priklad nepovolene tranzakce
BEGIN
	create_new_transfer(5, TO_DATE('2024-04-27', 'YYYY-MM-DD'), 1, 1, 0, 1, 2, 'XXX-007');
END;
/

-- MATERIALIZOVANY POHLED --
-- Pohled stara se najit nepovolene transakce
-- pro spusteni druhym clenem tymy
CREATE MATERIALIZED VIEW search_not_approved_transaction
NOLOGGING
CACHE
BUILD IMMEDIATE
REFRESH ON COMMIT AS
	SELECT Worker.ID_Worker, Client.ID_Client, BankTransaction.ID_Transaction
	FROM Client, BankTransaction, Worker
	WHERE Client.ID_Client = BankTransaction.assignClientId AND BankTransaction.approvedState = 0 AND BankTransaction.executeWorkerId = Worker.ID_Worker;


-- priklad pouziti prohledu
SELECT * FROM search_not_approved_transaction WHERE ID_Worker = 1;

-- EXPLAIN PLAN --
-- nalez poctu vypracovanych tranzakce pracovnikem banku
EXPLAIN PLAN FOR
SELECT Worker.ID_Worker, Worker.firstName, COUNT(BankTransaction.ID_Transaction) AS WORKED_WITH
FROM Worker, BankTransaction
WHERE BankTransaction.executeWorkerId = Worker.ID_Worker
GROUP BY Worker.ID_Worker, Worker.firstName;

-- output vykonnosti selectu z EXPLAIN PLAN
SELECT plan_table_output FROM table ( DBMS_XPLAN.DISPLAY() ); 

-- vytvareni indexu pro optimalizace
CREATE INDEX executeWorkerId_index ON BankTransaction(executeWorkerId);

-- optimalizovani  EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT Worker.ID_Worker, Worker.firstName, COUNT(BankTransaction.ID_Transaction) AS WORKED_WITH
FROM Worker, BankTransaction
WHERE BankTransaction.executeWorkerId = Worker.ID_Worker
GROUP BY Worker.ID_Worker, Worker.firstName;

-- output vykonnosti selectu z EXPLAIN PLAN
SELECT plan_table_output FROM table ( DBMS_XPLAN.DISPLAY() );

-- KOMPLEXNI SELECT --
-- kvalifikuje ucty na zaklade poctu ruznych druhu tranzakce
WITH account_analys AS(
	SELECT A.ID_Account as acc,
	(SELECT COUNT(*) FROM DepositTransaction WHERE depositTo = A.ID_Account) AS cntDeposit,
	(SELECT COUNT(*) FROM TransferTransaction WHERE transferFrom = A.ID_Account ) AS cntTransfer,
	(SELECT COUNT(*) FROM WithdrawalTransaction WHERE withdrawalFrom = A.ID_Account ) AS cntWithdrawal
	FROM Account A
)
SELECT C.ID_Client AS cl_id, C.firstName AS cl_name, C.secondName AS cl_second_name, C.email AS cl_mail, A.ID_Account AS id_acc, AA.cntDeposit, AA.cntTransfer, AA.cntWithdrawal,
	CASE
		WHEN AA.cntDeposit > AA.cntTransfer + AA.cntWithdrawal THEN 'Savings account'
		WHEN AA.cntTransfer > AA.cntDeposit + AA.cntWithdrawal THEN 'Communication account'
		WHEN AA.cntWithdrawal > AA.cntDeposit + AA.cntTransfer THEN 'Cash out account'
		ELSE 'Base using account'
		END AS acc_qualification
FROM
Client C
JOIN Account A ON C.ID_Client = A.AccountOwner
JOIN account_analys AA ON A.ID_Account = AA.acc;
