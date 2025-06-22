USE UserDB

CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(20),
    SubjectID VARCHAR(20),
    Is_Valid BIT
);

ALTER TABLE SubjectAllotments
ADD CreatedAt DATETIME DEFAULT GETDATE()

CREATE TABLE SubjectRequest (
    StudentID VARCHAR(20),
    SubjectID VARCHAR(20)
);

INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
('159103036', 'PO1496');

GO
CREATE PROCEDURE sp_UpdateSubjectAllotments
AS
BEGIN
    UPDATE SA
    SET Is_Valid = 0
    FROM SubjectAllotments SA
    INNER JOIN SubjectRequest SR ON SA.StudentID = SR.StudentID
    WHERE SA.Is_Valid = 1 AND SA.SubjectID <> SR.SubjectID
    INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
    SELECT SR.StudentID, SR.SubjectID, 1
    FROM SubjectRequest SR
    WHERE NOT EXISTS (
        SELECT 1
        FROM SubjectAllotments SA
        WHERE SA.StudentID = SR.StudentID AND SA.SubjectID = SR.SubjectID AND SA.Is_Valid = 1
    )
END
EXEC sp_UpdateSubjectAllotments;

SELECT StudentID,SubjectID,Is_Valid FROM SubjectAllotments WHERE StudentID = '159103036' 
ORDER BY CreatedAt DESC;

