/*************************************************************************************************************
 * @name			SignaturePadController
 * @author			Pablo Martinez <Pablo@beintelligent.nz>
 * @created			27 / 08 / 2022
 * @description		Class to manage the Signature Pad LWC
 * @TestClass		SignaturePadControllerTest
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2022-08-27		Pablo Martinez			Creation of the Class
 *
 **************************************************************************************************************/
public with sharing class SignaturePadController {
  /*********************************************************************************************************
   * @name			saveSignature
   * @author			Pablo Martinez <Pablo@beintelligent.nz>
   * @created			27 / 08 / 2022
   * @description		Method called by the signaturePad LWC to save a signature as a SF File and link it to a record if specified
   * @param			String jsonRequest : A JSON string with the object to save with the properties
   *                            String signatureString : Base64 encoded string with the signature
   *                			String extension : Extension of the file to save (png or jpg)
   *                            String title : Title of the file to save - Could be empty and a default title will be generated
   *                            Id recordId : Record Id to link the file to (in ContentDocumentLink) if required
   * @return			Response wrapper with an isSuccess flag, an error message (if any) and the content version, content document and content document link ids
   **********************************************************************************************************/
  @AuraEnabled
  public static Response saveSignature(String jsonRequest) {
    Response response = new Response();

    try {
      if (String.isNotEmpty(jsonRequest)) {
        Request request = (Request) JSON.deserialize(jsonRequest, Request.class);

        // if we have a signature string
        if (String.isNotEmpty(request.signatureString)) {
          // create the title to save is it's empty from the UI
          String titleToSave =
            (String.isEmpty(request.title) ? 'Signature - ' + System.now() : request.title) +
            '.' +
            request.extension;

          // create the contentVersion
          ContentVersion contentVersion = new ContentVersion();
          contentVersion.ContentLocation = 'S';
          contentVersion.PathOnClient = titleToSave;
          contentVersion.Origin = 'H';
          contentVersion.Title = titleToSave;
          contentVersion.VersionData = EncodingUtil.base64Decode(request.signatureString);
          insert contentVersion;

          // add the id to the response
          response.contentVersionId = contentVersion.Id;

          // Get the ContentDocumentId after saving the version and add it to the response
          response.contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id]
          .ContentDocumentId;

          // if we need to link it to a record, create the content document link
          if (String.isNotEmpty(request.recordId)) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.ContentDocumentId = response.contentDocumentId;
            contentDocLink.LinkedEntityId = request.recordId;
            contentDocLink.ShareType = 'I';
            contentDocLink.Visibility = 'AllUsers';
            insert contentDocLink;

            response.contentDocumentLinkId = contentDocLink.Id;
          }
        } else {
          response.isSuccess = false;
          response.errorMessage = 'A signature needs to be send to the method to be able to save it.';
        }
      } else {
        response.isSuccess = false;
        response.errorMessage = 'A JSON string with the object to save needs to be send to be able to save it.';
      }
    } catch (Exception e) {
      response.isSuccess = false;
      response.errorMessage = e.getMessage() + ' / ' + e.getStackTraceString();
    }

    return response;
  }

  /*********************************************************************************************************
   * @name			saveSignatureInvocable
   * @author			Pablo Martinez <Pablo@beintelligent.nz>
   * @created			27 / 08 / 2022
   * @description		Invocable method to be called by a flow to save the signature and link it to a record if required
   * @param			List<Request> inputs : A List of records to insert with the following properties
   *                            String signatureString : Base64 encoded string with the signature
   *                			String extension : Extension of the file to save (png or jpg)
   *                            String title : Title of the file to save - Could be empty and a default title will be generated
   *                            Id recordId : Record Id to link the file to (in ContentDocumentLink) if required
   * @return			List<Response> responses with an isSuccess flag, an error message (if any) and the content version, content document and content document link ids
   **********************************************************************************************************/
  @InvocableMethod(
    label='Save a Signature as file'
    category='Signature Pad'
    description='Method to save the signature as a Salesforce File and link it to a record if specified'
  )
  public static List<Response> saveSignatureInvocable(List<Request> inputs) {
    List<Response> responses = new List<Response>();

    for (Request input : inputs) {
      responses.add(saveSignature(JSON.serialize(input)));
    }

    return responses;
  }

  public class Request {
    @InvocableVariable(label='Base64 string with the Signature' required=true)
    public String signatureString;

    @InvocableVariable(label='Extension of the image to save (png or jpg)' required=true)
    public String extension;

    @InvocableVariable(label='Title for the file to save (A generic will be generated if empty)')
    public String title;

    @InvocableVariable(label='Id of the record to link the file to. If empty it will only create the file.')
    public Id recordId;
  }

  public class Response {
    @AuraEnabled
    @InvocableVariable(label='Was the save action a success?')
    public Boolean isSuccess;

    @AuraEnabled
    @InvocableVariable(label='Error message (if any)')
    public String errorMessage;

    @AuraEnabled
    @InvocableVariable(label='Content Version Id if successful')
    public Id contentVersionId;

    @AuraEnabled
    @InvocableVariable(label='Content Document Id if successful')
    public Id contentDocumentId;

    @AuraEnabled
    @InvocableVariable(label='Content Document Link Id if successful and required')
    public Id contentDocumentLinkId;

    public Response() {
      this.isSuccess = true;
      this.errorMessage = '';
    }
  }
}