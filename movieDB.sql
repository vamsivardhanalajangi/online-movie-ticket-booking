-- Create Theatres Table
CREATE TABLE Theatres (
    TheatreID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Location NVARCHAR(255) NOT NULL,
    TotalSeats INT NOT NULL CHECK (TotalSeats > 0),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create Movies Table
CREATE TABLE Movies (
    MovieID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    Genre NVARCHAR(50) NOT NULL,
    Duration INT NOT NULL CHECK (Duration > 0), -- Duration in minutes
    ReleaseDate DATE NOT NULL,
    Rating FLOAT CHECK (Rating >= 0 AND Rating <= 10), -- Rating between 0 and 10
    Description NVARCHAR(255),
    Director NVARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create Users Table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(15),
    IsAdmin BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);

-- Create ShowTimes Table
CREATE TABLE ShowTimes (
    ShowTimeID INT IDENTITY(1,1) PRIMARY KEY,
    MovieID INT NOT NULL,
    TheatreID INT NOT NULL,
    ShowDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    AvailableSeats INT NOT NULL CHECK (AvailableSeats >= 0),
    SeatAvailability NVARCHAR(MAX) NOT NULL, -- New column for seat availability
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (TheatreID) REFERENCES Theatres(TheatreID)
);

-- Create Bookings Table
CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    TheatreID INT NOT NULL,
    BookingDate DATETIME DEFAULT GETDATE(),
    ShowTimeID INT NOT NULL,
    NumberOfSeats INT NOT NULL CHECK (NumberOfSeats > 0),
    TotalPrice DECIMAL(10, 2) NOT NULL CHECK (TotalPrice >= 0),
    Status NVARCHAR(20) DEFAULT 'Pending',
    PaymentMethod NVARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (TheatreID) REFERENCES Theatres(TheatreID),
    FOREIGN KEY (ShowTimeID) REFERENCES ShowTimes(ShowTimeID)
);

-- Create Payments Table (optional)
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount >= 0),
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50),
    TransactionID NVARCHAR(100) UNIQUE,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Create Reviews Table (optional)
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5), -- Rating between 1 and 5
    Comment NVARCHAR(255),
    ReviewDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID)
);

-- Create BookingSeats Table
CREATE TABLE BookingSeats (
    BookingSeatID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT,
    SeatIndex INT, -- Index position in the SeatAvailability string
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Insert sample data into Theatres Table
INSERT INTO Theatres (Name, Location, TotalSeats) VALUES
('Grand Cinema', 'Downtown', 100),
('Movie Palace', 'Uptown', 200);

-- Insert sample data into Movies Table
INSERT INTO Movies (Title, Genre, Duration, ReleaseDate, Rating, Description, Director) VALUES
('Inception', 'Sci-Fi', 148, '2010-07-16', 8.8, 'A thief who steals corporate secrets through the use of dream-sharing technology.', 'Christopher Nolan'),
('The Matrix', 'Action', 136, '1999-03-31', 8.7, 'A computer hacker learns from mysterious rebels about the true nature of his reality.', 'Lana Wachowski, Lilly Wachowski');

-- Insert sample data into Users Table
INSERT INTO Users (Username, PasswordHash, Email, FullName, PhoneNumber, IsAdmin) VALUES
('john_doe', 'hash1', 'john@example.com', 'John Doe', '1234567890', 0),
('admin_user', 'hash2', 'admin@example.com', 'Admin User', '0987654321', 1);

-- Insert sample data into ShowTimes Table
INSERT INTO ShowTimes (MovieID, TheatreID, ShowDate, StartTime, EndTime, AvailableSeats, SeatAvailability) VALUES
(1, 1, '2024-08-10', '18:00', '20:28', 100, '11111111110000000000'), -- 10 seats available
(2, 2, '2024-08-11', '20:00', '22:16', 200, '11111111111111111111'); -- 20 seats available

-- Insert sample data into Bookings Table
INSERT INTO Bookings (UserID, MovieID, TheatreID, ShowTimeID, NumberOfSeats, TotalPrice, Status, PaymentMethod) VALUES
(1, 1, 1, 1, 2, 20.00, 'Confirmed', 'Credit Card'),
(1, 2, 2, 2, 1, 10.00, 'Confirmed', 'Debit Card');

-- Insert sample data into BookingSeats Table
INSERT INTO BookingSeats (BookingID, SeatIndex) VALUES
(1, 0), -- A1 as 0th index
(1, 1), -- A2 as 1st index
(2, 2); -- B1 as 2nd index

-- Insert sample data into Payments Table
INSERT INTO Payments (BookingID, Amount, PaymentMethod, TransactionID) VALUES
(1, 20.00, 'Credit Card', 'TXN123456'),
(2, 10.00, 'Debit Card', 'TXN654321');

-- Insert sample data into Reviews Table
INSERT INTO Reviews (UserID, MovieID, Rating, Comment) VALUES
(1, 1, 5, 'Amazing movie!'),
(1, 2, 4, 'Great action scenes.');

-- 1. Retrieve All Movies with Their Details
SELECT MovieID, Title, Genre, Duration, ReleaseDate, Rating, Description, Director
FROM Movies;

-- 2. Find Available Showtimes for a Specific Movie
-- Replace 1 with the desired MovieID
SELECT s.ShowTimeID, t.Name AS TheatreName, s.ShowDate, s.StartTime, s.EndTime, s.AvailableSeats
FROM ShowTimes s
JOIN Theatres t ON s.TheatreID = t.TheatreID
WHERE s.MovieID = 1;

-- 3. Retrieve All Bookings Made by a Specific User with Seat Numbers
-- Replace 1 with the desired UserID
SELECT b.BookingID, m.Title, t.Name AS TheatreName, b.BookingDate, b.NumberOfSeats, b.TotalPrice, b.Status, bs.SeatIndex
FROM Bookings b
JOIN Movies m ON b.MovieID = m.MovieID
JOIN Theatres t ON b.TheatreID = t.TheatreID
JOIN BookingSeats bs ON b.BookingID = bs.BookingID
WHERE b.UserID = 1;

-- 4. Calculate Total Revenue from Bookings
SELECT SUM(TotalPrice) AS TotalRevenue
FROM Bookings;

-- 5. Retrieve Reviews for a Specific Movie
-- Replace 1 with the desired MovieID
SELECT r.ReviewID, u.FullName, r.Rating, r.Comment, r.ReviewDate
FROM Reviews r
JOIN Users u ON r.UserID = u.UserID
WHERE r.MovieID = 1;

-- 6. Get the Most Popular Movies Based on Ratings
SELECT m.MovieID, m.Title, AVG(r.Rating) AS AverageRating
FROM Movies m
LEFT JOIN Reviews r ON m.MovieID = r.MovieID
GROUP BY m.MovieID, m.Title
ORDER BY AverageRating DESC;

-- 7. Get Available Seats for a Specific Showtime
-- Replace 1 with the desired ShowTimeID
SELECT AvailableSeats
FROM ShowTimes
WHERE ShowTimeID = 1;

-- 8. Update Available Seats After a Booking
-- Replace with the actual number of seats booked and the desired ShowTimeID
UPDATE ShowTimes
SET AvailableSeats = AvailableSeats - 2 
WHERE ShowTimeID = 1;

-- 9. Retrieve All Theatres with Their Movies
SELECT t.Name AS TheatreName, m.Title AS MovieTitle
FROM Theatres t
JOIN ShowTimes s ON t.TheatreID = s.TheatreID
JOIN Movies m ON s.MovieID = m.MovieID
ORDER BY t.Name, m.Title;

-- 10. Get Users Who Have Made Bookings
SELECT DISTINCT u.UserID, u.FullName, u.Email
FROM Users u
JOIN Bookings b ON u.UserID = b.UserID;

-- 11. Get Booking Details by Booking ID with Seat Numbers
-- Replace 1 with the desired BookingID
SELECT b.BookingID, m.Title, t.Name AS TheatreName, b.BookingDate, b.NumberOfSeats, b.TotalPrice, b.Status, bs.SeatIndex
FROM Bookings b
JOIN Movies m ON b.MovieID = m.MovieID
JOIN Theatres t ON b.TheatreID = t.TheatreID
JOIN BookingSeats bs ON b.BookingID = bs.BookingID
WHERE b.BookingID = 1;

-- 12. Get Total Bookings and Revenue per Movie
SELECT m.Title, COUNT(b.BookingID) AS TotalBookings, SUM(b.TotalPrice) AS TotalRevenue
FROM Movies m
LEFT JOIN Bookings b ON m.MovieID = b.MovieID
GROUP BY m.Title;

-- 13. Get Upcoming Shows for a Specific Theatre
-- Replace 1 with the desired TheatreID
SELECT s.ShowTimeID, m.Title, s.ShowDate, s.StartTime, s.EndTime, s.AvailableSeats
FROM ShowTimes s
JOIN Movies m ON s.MovieID = m.MovieID
WHERE s.TheatreID = 1 AND s.ShowDate >= CAST(GETDATE() AS DATE)
ORDER BY s.ShowDate, s.StartTime;

-- 14. Get Total Number of Users Registered
SELECT COUNT(UserID) AS TotalUsers
FROM Users;

-- 15. Get All Movies Released in a Specific Year
-- Replace 2024 with the desired year
SELECT *
FROM Movies
WHERE YEAR(ReleaseDate) = 2024;

-- 16. Get Theatres Showing a Specific Movie
-- Replace 1 with the desired MovieID
SELECT DISTINCT t.Name AS TheatreName
FROM Theatres t
JOIN ShowTimes s ON t.TheatreID = s.TheatreID
WHERE s.MovieID = 1;

-- 17. Get All Upcoming Movies with Their Release Dates
SELECT Title, ReleaseDate
FROM Movies
WHERE ReleaseDate >= CAST(GETDATE() AS DATE)
ORDER BY ReleaseDate;

-- 18. Get User Booking History with Movies and Theatres
-- Replace 1 with the desired UserID
SELECT b.BookingID, m.Title, t.Name AS TheatreName, b.BookingDate, b.NumberOfSeats, b.TotalPrice, b.Status
FROM Bookings b
JOIN Movies m ON b.MovieID = m.MovieID
JOIN Theatres t ON b.TheatreID = t.TheatreID
WHERE b.UserID = 1
ORDER BY b.BookingDate DESC;

-- 19. Get Total Bookings Per User
SELECT u.UserID, u.FullName, COUNT(b.BookingID) AS TotalBookings
FROM Users u
LEFT JOIN Bookings b ON u.UserID = b.UserID
GROUP BY u.UserID, u.FullName
ORDER BY TotalBookings DESC;

-- 20. Get Movies with Average Ratings Below a Certain Threshold
-- Replace 4 with the desired rating threshold
SELECT m.Title, AVG(r.Rating) AS AverageRating
FROM Movies m
LEFT JOIN Reviews r ON m.MovieID = r.MovieID
GROUP BY m.MovieID, m.Title
HAVING AVG(r.Rating) < 4;

-- 21. Get Available Showtimes for All Movies in a Specific Theatre
-- Replace 1 with the desired TheatreID
SELECT m.Title, s.ShowTimeID, s.ShowDate, s.StartTime, s.EndTime, s.AvailableSeats
FROM ShowTimes s
JOIN Movies m ON s.MovieID = m.MovieID
WHERE s.TheatreID = 1 AND s.AvailableSeats > 0
ORDER BY s.ShowDate, s.StartTime;

-- 22. Get Total Revenue Per Movie
SELECT m.Title, SUM(b.TotalPrice) AS TotalRevenue
FROM Movies m
LEFT JOIN Bookings b ON m.MovieID = b.MovieID
GROUP BY m.Title
ORDER BY TotalRevenue DESC;

-- 23. Get Users Who Have Left Reviews
SELECT DISTINCT u.UserID, u.FullName
FROM Users u
JOIN Reviews r ON u.UserID = r.UserID;

-- 24. Get Most Recent Bookings
SELECT TOP 10 b.BookingID, m.Title, t.Name AS TheatreName, b.BookingDate, b.NumberOfSeats, b.TotalPrice, b.Status
FROM Bookings b
JOIN Movies m ON b.MovieID = m.MovieID
JOIN Theatres t ON b.TheatreID = t.TheatreID
ORDER BY b.BookingDate DESC;

-- 25. Get All Showtimes for a Specific Movie in a Specific Theatre
-- Replace 1 with the desired MovieID and 1 with the desired TheatreID
SELECT s.ShowTimeID, s.ShowDate, s.StartTime, s.EndTime, s.AvailableSeats
FROM ShowTimes s
WHERE s.MovieID = 1 AND s.TheatreID = 1
ORDER BY s.ShowDate, s.StartTime;

