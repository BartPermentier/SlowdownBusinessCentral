pageextension 80031 "BPEItemList" extends "Item List" //31
{
    layout
    {

    }

    actions
    {
        addafter("Item Reclassification Journal")
        {
            group(BPE)
            {
                action(BPEDuplicateSelectedItem)
                {
                    Caption = 'Duplicate Selected Item...';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Copy;
                    trigger OnAction()
                    var
                        TempInteger: Record Integer temporary;
                        Result: text;
                        NoOfCopies: Integer;
                        i: Integer;
                    begin
                        Result := RequestNewValueForAField(TempInteger, 1, '10000');
                        Evaluate(NoOfCopies, Result);
                        Rec."No." := Rec."No." + '1';
                        repeat
                            i += 1;
                            Rec."No." := Copystr(IncStr(Rec."No."), 1, MaxStrLen(rec."No."));
                            if Rec.Insert() then
                                Commit();
                        until i = NoOfCopies;
                    end;
                }
                action(BPECountNoOfItems)
                {
                    Caption = 'Count No Of Items';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    trigger OnAction()
                    begin
                        Message(Format(Rec.Count()));
                    end;
                }
                action(BPECreatePrices)
                {
                    Caption = 'Create Prices';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        SalesPrice: Record "Sales Price";
                        CustomerPriceGroup: Record "Customer Price Group";
                        i: Integer;
                        j: Integer;
                    begin
                        Findset();
                        repeat
                            j += 1;
                            //Create cust price groups
                            if not CustomerPriceGroup.FindSet() then begin
                                repeat
                                    i += 1;
                                    CustomerPriceGroup.Init();
                                    CustomerPriceGroup.Code := Copystr(format(i), 1, 10);
                                    CustomerPriceGroup.Insert();
                                until i = 3;
                                CustomerPriceGroup.FindSet();
                            end;

                            //create prices
                            i := 0;
                            repeat
                                i += 1;
                                SalesPrice.Init();
                                SalesPrice."Sales Type" := SalesPrice."Sales Type"::"Customer Price Group";
                                SalesPrice."Sales Code" := CustomerPriceGroup.Code;
                                SalesPrice."Item No." := "No.";
                                SalesPrice."Unit of Measure Code" := "Base Unit of Measure";
                                SalesPrice."Unit Price" := "Unit Price" + i;
                                SalesPrice.insert();
                                commit();
                            until CustomerPriceGroup.Next() = 0;
                        until (Next() = 0) or (j = 10000);
                    end;
                }
                action(BPECountNoOfPrices)
                {
                    Caption = 'Count No Of Prices';
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        SalesPrice: Record "Sales Price";
                    begin
                        Message(Format(SalesPrice.Count()));
                    end;
                }
            }

        }
    }

    procedure RequestNewValueForAField(PVar_Variant: Variant; PInt_FieldNo: Integer; PTxt_InitialValue: Text) RTxt_Result: Text;
    var
        FilterPage: FilterPageBuilder;
        FldRef: FieldRef;
        RecRef: RecordRef;
        ModifyFieldLbl: Label 'Copy how many times?';
        Filters: Text;
        StrPosition: Integer;
        ToManyParametersErr: Label 'You have used to many parameters. Please only use 1.';
    begin

        FilterPage.PageCaption(ModifyFieldLbl);
        FilterPage.AddRecord(ModifyFieldLbl, PVar_Variant);
        RecRef.GetTable(PVar_Variant);
        FldRef := RecRef.FIELD(PInt_FieldNo);
        FilterPage.AddField(ModifyFieldLbl, FldRef, PTxt_InitialValue);
        if not FilterPage.RunModal() then Error('');
        RecRef.SetView(FilterPage.GETVIEW(ModifyFieldLbl));
        Filters := RecRef.GetFilters();
        StrPosition := StrPos(Filters, ':');
        Filters := CopyStr(Filters, StrPosition + 2);
        StrPosition := StrPos(Filters, ':');
        if StrPosition <> 0 then
            Error(ToManyParametersErr);
        exit(Filters);
    end;


}