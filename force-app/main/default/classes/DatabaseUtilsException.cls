global with sharing class DatabaseUtilsException extends Exception {
    global enum ExceptionType {
        GENERIC,
        OBJECT_ACCESS_VIOLATION,
        FIELD_ACCESS_VIOLATION,
        SHARING_ACCESS_VIOLATION,
        NO_RECORD_FOUND,
        FIELD_NOT_FOUND
    }

    global enum ExceptionReason {
        GENERIC,
        NO_CREATE,
        NO_READ,
        NO_UPDATE,
        NO_DELETE
    }

    private ExceptionType eType;
    private ExceptionReason eReason;
    private String eObject;
    private String eField;
    private String eText;

    global DatabaseUtilsException(String eText, ExceptionType eType, ExceptionReason eReason, String eObject, String eField) {
        this.eText = eText;
        this.eType = eType;
        this.eReason = eReason;
        this.eObject = eObject;
        this.eField = eField;
    }

    global ExceptionType getExceptionType() {
        return this.eType;
    }

    global ExceptionReason getExceptionReason() {
        return this.eReason;
    }

    global String getExceptionObject() {
        return this.eObject;
    }

    global String getExceptionField() {
        return this.eField;
    }

    global String getText() {
        return this.eText;
    }

    global override String getMessage() {
        return this.eText;
    }

}