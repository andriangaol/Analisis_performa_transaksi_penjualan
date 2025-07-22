create database schoters_;
show databases;
use schoters_;

ALTER TABLE `schoters_`.`transaksi_` 
ADD COLUMN `ID Transaksi` INT AUTO_INCREMENT PRIMARY KEY first,
CHANGE COLUMN `Tanggal Transaksi` `Tanggal Transaksi` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `Nama Sales` `Nama Sales` VARCHAR(20) NULL DEFAULT NULL ,
CHANGE COLUMN `Harga Asli` `Harga Asli` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Customer` `Customer` VARCHAR(20) NULL DEFAULT NULL ,
CHANGE COLUMN `Tipe Produk` `Tipe Produk` VARCHAR(20) NULL DEFAULT NULL ;

ALTER TABLE `schoters_`.`campaign_` 
ADD COLUMN `ID Campaign` INT AUTO_INCREMENT PRIMARY KEY first,
DROP COLUMN `End Date_[0]`,
DROP COLUMN `MyUnknownColumn`,
CHANGE COLUMN `Name` `Name` VARCHAR(20) NULL DEFAULT NULL ,
CHANGE COLUMN `Start Date` `Start Date` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `End Date` `End Date` DATE NULL DEFAULT NULL ,
CHANGE COLUMN `Budget` `Budget` INT NULL DEFAULT NULL ;

ALTER TABLE `schoters_`.`customer` 
ADD COLUMN `ID Customer` INT AUTO_INCREMENT PRIMARY KEY first,
CHANGE COLUMN `Name` `Name` VARCHAR(20) NULL DEFAULT NULL ,
CHANGE COLUMN `Domisili` `Domisili` VARCHAR(20) NULL DEFAULT NULL ;

SHOW CREATE TABLE transaksi_;

-- a. Total transaksi dari masing-masing customer
CREATE VIEW `Transaksi Customer` AS
SELECT Customer,  
	SUM(t.`Harga Asli`) AS `Total Transaksi`
FROM transaksi_ as t
GROUP BY Customer;

select * from `Transaksi Customer`;

-- b. Total transaksi dari masing-masing kota.
CREATE VIEW `Transaksi Kota` AS
SELECT 
	c.Domisili, SUM(t.`Harga Asli`) AS `Total Transaksi`
FROM customer as c
JOIN transaksi_ as t ON c.Name = t.Customer
GROUP BY c.Domisili
ORDER BY `Total Transaksi` DESC;

select * from `Transaksi Kota`;

-- c. Lakukanlah EDA (Exploratory Data Analysis) pada data tersebut melalui MySQL.
-- 1. Penghapusan Data Kosong

DELETE FROM campaign_
WHERE `ID Campaign` IS NULL 
AND `Name` IS NULL 
AND `Start Date` IS NULL
AND `End Date` IS NULL
AND `Budget` IS NULL;
select * from campaign_;

DELETE FROM customer
WHERE `ID Customer` IS NULL 
AND `Name` IS NULL 
AND `Domisili` IS NULL
AND `Usia` IS NULL;
select * from customer;

DELETE FROM transaksi_
WHERE `ID Transaksi` IS NULL 
AND `Tanggal Transaksi` IS NULL 
AND `Nama Sales` IS NULL 
AND `Harga Asli` IS NULL
AND `Customer` IS NULL
AND `Tipe Produk` IS NULL;
select * from transaksi_;

-- 2. insight 
-- Tipe Produk
CREATE VIEW `Data Tipe Produk` AS
SELECT `Tipe Produk`,  
	COUNT(*) AS `Jumlah`,
    SUM(t.`Harga Asli`) as `Total Harga`
FROM transaksi_ as t
GROUP BY `Tipe Produk`
ORDER BY `Total Harga` DESC;
select * from `Data Tipe Produk`;

-- total transaksi setiap bulan
CREATE VIEW `Transaksi Bulanan` AS
SELECT
    DATE_FORMAT(`Tanggal Transaksi`, '%Y-%m') AS Bulan,
    COUNT(*) AS `Jumlah Transaksi`
FROM transaksi_
GROUP BY Bulan
ORDER BY Bulan;

select * from `Transaksi Bulanan`;

-- statistik deskriptif keseluruhan
SELECT
    tk.Domisili AS `Domisili dengan Transaksi Terbanyak`,
    tk.`Total transaksi`,
    tc.Customer AS `Customer dengan Transaksi Terbanyak`,
    tc.`Total transaksi`,
    tb.Bulan AS `Bulan dengan Transaksi Terbanyak`,
    tb.`Jumlah Transaksi`,
    dtp.`Tipe Produk` AS `Tipe Produk dengan Transaksi Terbanyak`,
    dtp.`Jumlah`,
    dtp.`Total Harga`
FROM
    `Transaksi Kota` AS tk
JOIN
    `Transaksi Customer` AS tc,
    `Transaksi Bulanan` AS tb,
    `Data Tipe Produk` as dtp
WHERE
    tc.`Total transaksi` = (
        SELECT MAX(`Total transaksi`)
        FROM `Transaksi Customer`
    )
    AND tk.`Total transaksi` = (
        SELECT MAX(`Total transaksi`)
        FROM `Transaksi Kota`
    )
    AND tb.`Jumlah Transaksi` = (
        SELECT MAX(`Jumlah Transaksi`)
        FROM `Transaksi Bulanan`
    )
    AND dtp.`Jumlah`=(
		SELECT MAX(`Jumlah`)
        FROM  `Data Tipe Produk`
	);
    
    -- statistik deskriptif transaksi customer
    SELECT 
		AVG(`Total transaksi`) as `Rata-Rata Transaksi`,
        MAX(`Total transaksi`) as `Maksimum Transaksi`,
        (SELECT Customer 
		FROM `Transaksi Customer` 
		WHERE `Total transaksi` = ((SELECT MAX(`Total transaksi`) FROM `Transaksi Customer`)) ) AS `Customer dengan Transaksi Maksimum`,
        MIN(`Total transaksi`) as `Minimum Transaksi`,
        (SELECT Customer 
		FROM `Transaksi Customer` 
		WHERE `Total transaksi` = ((SELECT MIN(`Total transaksi`) FROM `Transaksi Customer`)) ) AS `Customer dengan Transaksi Minimum`,
        (SELECT
        Customer
			FROM
				(SELECT Customer,
					COUNT(Customer) AS frekuensi
				FROM `transaksi customer`
				GROUP BY Customer
				ORDER BY frekuensi DESC LIMIT 1) AS subquery) AS `Customer Dengan Transaksi Terbanyak`
    FROM `Transaksi Customer`;
    
    -- statistik deskriptif transaksi bulanan
    SELECT 
    AVG(`Jumlah transaksi`) AS `Rata-Rata Transaksi`,
    MAX(`Jumlah transaksi`) AS `Maksimum Transaksi`,
    (SELECT Bulan 
		FROM `Transaksi Bulanan` 
		WHERE `Jumlah transaksi` = ((SELECT MAX(`Jumlah transaksi`) FROM `Transaksi Bulanan`)) ) AS `Bulan Maksimum`,
    MIN(`Jumlah transaksi`) AS `Minimum Transaksi`,
    (SELECT Bulan 
		FROM `Transaksi Bulanan` 
        WHERE `Jumlah transaksi` = ((SELECT MIN(`Jumlah transaksi`) FROM `Transaksi Bulanan`)) ) AS `Bulan Minimum`
FROM `Transaksi Bulanan`;

-- statistik deskriptif transaksi kota
    SELECT 
    AVG(`Total transaksi`) AS `Rata-Rata Transaksi`,
    MAX(`Total transaksi`) AS `Maksimum Transaksi`,
    (SELECT Domisili 
		FROM `Transaksi Kota` 
		WHERE `Total transaksi` = ((SELECT MAX(`Total transaksi`) FROM `Transaksi Kota`)) ) AS `Kota Dengan Transaksi Maksimum`,
    MIN(`Total transaksi`) AS `Minimum Transaksi`,
    (SELECT Domisili 
		FROM `Transaksi Kota` 
        WHERE `Total transaksi` = ((SELECT MIN(`Total transaksi`) FROM `Transaksi Kota`)) ) AS `Kota Dengan Transaksi Minimum`
FROM `Transaksi Kota`;

-- statistik deskriptif tipe produk
SELECT 
    AVG(`Total Harga`) AS `Rata-Rata Total Harga `,
    MAX(`Total Harga`) AS `Maksimum Transaksi`,
    (SELECT `Tipe Produk` 
		FROM `data tipe produk` 
		WHERE `Total Harga` = ((SELECT MAX(`Total Harga`) FROM `Data Tipe Produk`)) ) AS `Tipe Produk Dengan Total Harga Maksimum`,
    MIN(`Total Harga`) AS `Minimum Transaksi`,
    (SELECT `Tipe Produk` 
		FROM `data tipe produk` 
		WHERE `Total Harga` = ((SELECT MIN(`Total Harga`) FROM `Data Tipe Produk`)) ) AS `Tipe Produk Dengan Total Harga minimum`,
	MAX(`Jumlah`) AS `Jumlah Tipe Produk MInimum`,
    (SELECT `Tipe Produk` 
		FROM `data tipe produk` 
		WHERE `Jumlah` = ((SELECT MIN(`Jumlah`) FROM `Data Tipe Produk`)) ) AS `Tipe Produk Dengan Total Minimum`,
	MIN(`Jumlah`) AS `Jumlah Tipe Produk MInimum`,
    (SELECT `Tipe Produk` 
		FROM `data tipe produk` 
		WHERE `Jumlah` = ((SELECT MAX(`Jumlah`) FROM `Data Tipe Produk`)) ) AS `Tipe Produk Dengan Total Maksimum`
FROM `data tipe produk`;


    





