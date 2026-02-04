create PROCEDURE        add_error_log (
    err_name  varchar2,
    err_desc  varchar2,
    ser_id   number
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    INSERT INTO ETP_API_ERROR_LOG
                     VALUES (
                                err_name,
                                err_desc,
                                ser_id,
                                SYSDATE);

            COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END add_error_log;
/

