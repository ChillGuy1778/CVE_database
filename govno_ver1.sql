-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema security_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema security_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `security_db` ;
USE `security_db` ;

-- -----------------------------------------------------
-- Table `security_db`.`system`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `security_db`.`system` ;

CREATE TABLE IF NOT EXISTS `security_db`.`system` (
  `id_system` INT NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(255) NOT NULL,
  `version` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_system`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `security_db`.`company`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `security_db`.`company` ;

CREATE TABLE IF NOT EXISTS `security_db`.`company` (
  `id_company` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `domain` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_company`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `security_db`.`cve`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `security_db`.`cve` ;

CREATE TABLE IF NOT EXISTS `security_db`.`cve` (
  `id_cve` INT UNSIGNED NOT NULL,
  `date_publish` DATE NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  `required_action` VARCHAR(45) NOT NULL,
  `CVSS_score` DOUBLE UNSIGNED ZEROFILL NOT NULL DEFAULT 0,
  `status` TINYINT NOT NULL DEFAULT 0,
  `id_system` INT NULL,
  `id_company` INT NULL,
  PRIMARY KEY (`id_cve`),
  INDEX `id_cve` (`id_cve` ASC) VISIBLE,
  INDEX `id_system_idx` (`id_system` ASC) VISIBLE,
  INDEX `for_company_idx` (`id_company` ASC) VISIBLE,
  CONSTRAINT `from_system`
    FOREIGN KEY (`id_system`)
    REFERENCES `security_db`.`system` (`id_system`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `for_company`
    FOREIGN KEY (`id_company`)
    REFERENCES `security_db`.`company` (`id_company`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `security_db`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `security_db`.`user` ;

CREATE TABLE IF NOT EXISTS `security_db`.`user` (
  `id_user` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `surname` VARCHAR(45) NOT NULL,
  `mail` VARCHAR(45) NOT NULL,
  `birthday` DATE NOT NULL,
  `id_company` INT NOT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE INDEX `mail_UNIQUE` (`mail` ASC) VISIBLE,
  INDEX `id_company_idx` (`id_company` ASC) VISIBLE,
  CONSTRAINT `id_company`
    FOREIGN KEY (`id_company`)
    REFERENCES `security_db`.`company` (`id_company`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
