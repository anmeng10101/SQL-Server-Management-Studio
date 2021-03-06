USE [master]
GO
/****** Object:  Database [DEPLcontrol]    Script Date: 10/4/2013 11:02:03 AM ******/
CREATE DATABASE [DEPLcontrol] ON  PRIMARY 
( NAME = N'DEPLcontrol', FILENAME = N'E:\mssql\data\DEPLcontrol.mdf' , SIZE = 569344KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DEPLcontrol_log', FILENAME = N'E:\mssql\data\DEPLcontrol_log.ldf' , SIZE = 4096KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DEPLcontrol] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DEPLcontrol].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [DEPLcontrol] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DEPLcontrol] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DEPLcontrol] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DEPLcontrol] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DEPLcontrol] SET ARITHABORT OFF 
GO
ALTER DATABASE [DEPLcontrol] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DEPLcontrol] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [DEPLcontrol] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DEPLcontrol] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DEPLcontrol] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DEPLcontrol] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DEPLcontrol] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DEPLcontrol] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DEPLcontrol] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DEPLcontrol] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DEPLcontrol] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DEPLcontrol] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DEPLcontrol] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DEPLcontrol] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DEPLcontrol] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DEPLcontrol] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DEPLcontrol] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DEPLcontrol] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DEPLcontrol] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DEPLcontrol] SET  MULTI_USER 
GO
ALTER DATABASE [DEPLcontrol] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DEPLcontrol] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'DEPLcontrol', N'ON'
GO
USE [DEPLcontrol]
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' 
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'EnableCodeComments', @value=N'0' 
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'DeplFileName', @value=N'' 
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'BuildNumber', @value=N'' 
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'BuildBranch', @value=N'' 
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'BuildApplication', @value=N'' 
GO
EXEC [DEPLcontrol].sys.sp_addextendedproperty @name=N'AllowRollback', @value=N'1' 
GO
USE [master]
GO
ALTER DATABASE [DEPLcontrol] SET  READ_WRITE 
GO
