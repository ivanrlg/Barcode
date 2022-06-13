permissionset 60122 Permissionset
{
    Assignable = true;
    Caption = 'Permissionset';

    Permissions = tabledata "Barcode Setup" = RIMD,
                  table "Barcode Setup" = X,
                  codeunit Helper = X,
                  page "Barcode Setup Part" = X,
                  page BarcodeSetup = X;
}