@IsTest
public class SignaturePadControllerTest {
  @TestSetup
  static void setup() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
  }

  @IsTest
  static void testSaveSignatureAuraSuccessAndLink() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = acc.Id;
    request.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request.title = 'Signature for ' + acc.Name;

    Test.startTest();

    SignaturePadController.Response response = SignaturePadController.saveSignature(JSON.serialize(request));

    Test.stopTest();

    cdls = [
      SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(1, cdls.size(), 'There is no file linked to the account');
    System.assertEquals(cdls[0].ContentDocumentId, response.contentDocumentId, 'Different file id');
    System.assertEquals(cdls[0].Id, response.contentDocumentLinkId, 'Different file link id');
    System.assertEquals(cdls[0].ContentDocument.Title, request.title + '.' + request.extension, 'Different file title');
    System.assertNotEquals(null, response.contentVersionId, 'The file version was not created');
    System.assertEquals(true, response.isSuccess, 'The save was not successful');
    System.assertEquals('', response.errorMessage, 'There is an error message when saving');
  }

  @IsTest
  static void testSaveSignatureAuraSuccessNoLink() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = null;
    request.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request.title = 'Signature for ' + acc.Name;

    Test.startTest();

    SignaturePadController.Response response = SignaturePadController.saveSignature(JSON.serialize(request));

    Test.stopTest();

    cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');
    System.assertNotEquals(null, response.contentDocumentId, 'The file was not created');
    System.assertNotEquals(null, response.contentVersionId, 'The file version was not created');
    System.assertEquals(null, response.contentDocumentLinkId, 'There is a content document link id');
    System.assertEquals(true, response.isSuccess, 'The save was not successful');
    System.assertEquals('', response.errorMessage, 'There is an error message when saving');
  }

  @IsTest
  static void testSaveSignatureAuraFailedNoSignature() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = acc.Id;
    request.signatureString = null;
    request.title = 'Signature for ' + acc.Name;

    Test.startTest();

    SignaturePadController.Response response = SignaturePadController.saveSignature(JSON.serialize(request));

    Test.stopTest();

    cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');
    System.assertEquals(null, response.contentDocumentId, 'The file was created');
    System.assertEquals(null, response.contentVersionId, 'The file version was created');
    System.assertEquals(null, response.contentDocumentLinkId, 'There is a content document link id');
    System.assertEquals(false, response.isSuccess, 'The save was successful');
    System.assertEquals(
      'A signature needs to be send to the method to be able to save it.',
      response.errorMessage,
      'Different error message when saving'
    );
  }

  @IsTest
  static void testSaveSignatureAuraFailedNoInput() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    Test.startTest();

    SignaturePadController.Response response = SignaturePadController.saveSignature(null);

    Test.stopTest();

    cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');
    System.assertEquals(null, response.contentDocumentId, 'The file was created');
    System.assertEquals(null, response.contentVersionId, 'The file version was created');
    System.assertEquals(null, response.contentDocumentLinkId, 'There is a content document link id');
    System.assertEquals(false, response.isSuccess, 'The save was successful');
    System.assertEquals(
      'A JSON string with the object to save needs to be send to be able to save it.',
      response.errorMessage,
      'Different error message when saving'
    );
  }

  @IsTest
  static void testSaveSignatureAuraFailedCatch() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = null;
    request.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request.title = 'Signature for ' + acc.Name;

    Test.startTest();

    SignaturePadController.Response response = SignaturePadController.saveSignature(
      JSON.serialize(new List<SignaturePadController.Request>{ request })
    );

    Test.stopTest();

    cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');
    System.assertEquals(null, response.contentDocumentId, 'The file was created');
    System.assertEquals(null, response.contentVersionId, 'The file version was created');
    System.assertEquals(null, response.contentDocumentLinkId, 'There is a content document link id');
    System.assertEquals(false, response.isSuccess, 'The save was successful');
    System.assert(
      response.errorMessage.contains('Malformed JSON: Expected \'{\' at the beginning of object '),
      'Different error message when saving'
    );
  }

  @IsTest
  static void testSaveSignatureInvocableSeveralSuccessAndLinks() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = acc.Id;
    request.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request.title = '1 Signature for ' + acc.Name;

    SignaturePadController.Request request1 = new SignaturePadController.Request();
    request1.extension = 'jpg';
    request1.recordId = acc.Id;
    request1.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request1.title = '2 Signature for ' + acc.Name;

    Test.startTest();

    List<SignaturePadController.Response> responses = SignaturePadController.saveSignatureInvocable(
      new List<SignaturePadController.Request>{ request, request1 }
    );

    Test.stopTest();

    cdls = [
      SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(2, cdls.size(), 'There is no file linked to the account');
    System.assertEquals(cdls[0].ContentDocumentId, responses[0].contentDocumentId, 'Different first file id');
    System.assertEquals(cdls[0].Id, responses[0].contentDocumentLinkId, 'Different first file link id');
    System.assertEquals(
      cdls[0].ContentDocument.Title,
      request.title +
      '.' +
      request.extension,
      'Different first file title'
    );
    System.assertNotEquals(null, responses[0].contentVersionId, 'The first file version was not created');
    System.assertEquals(true, responses[0].isSuccess, 'The first save was not successful');
    System.assertEquals('', responses[0].errorMessage, 'There is an error message when saving the first file');
    System.assertEquals(cdls[1].ContentDocumentId, responses[1].contentDocumentId, 'Different second file id');
    System.assertEquals(cdls[1].Id, responses[1].contentDocumentLinkId, 'Different second file link id');
    System.assertEquals(
      cdls[1].ContentDocument.Title,
      request1.title +
      '.' +
      request1.extension,
      'Different second file title'
    );
    System.assertNotEquals(null, responses[1].contentVersionId, 'The second file version was not created');
    System.assertEquals(true, responses[1].isSuccess, 'The second save was not successful');
    System.assertEquals('', responses[1].errorMessage, 'There is an error message when saving the second file');
  }

  @IsTest
  static void testSaveSignatureInvocableSeveralSuccessNoLinks() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = null;
    request.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request.title = '1 Signature for ' + acc.Name;

    SignaturePadController.Request request1 = new SignaturePadController.Request();
    request1.extension = 'jpg';
    request1.recordId = null;
    request1.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request1.title = '2 Signature for ' + acc.Name;

    Test.startTest();

    List<SignaturePadController.Response> responses = SignaturePadController.saveSignatureInvocable(
      new List<SignaturePadController.Request>{ request, request1 }
    );

    Test.stopTest();

    cdls = [
      SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is no file linked to the account');
    System.assertNotEquals(null, responses[0].contentDocumentId, 'First File was not created');
    System.assertEquals(null, responses[0].contentDocumentLinkId, 'The first link was created');
    System.assertNotEquals(null, responses[0].contentVersionId, 'The first file version was not created');
    System.assertEquals(true, responses[0].isSuccess, 'The first save was not successful');
    System.assertEquals('', responses[0].errorMessage, 'There is an error message when saving the first file');
    System.assertNotEquals(null, responses[1].contentDocumentId, 'Second File was not created');
    System.assertEquals(null, responses[1].contentDocumentLinkId, 'The second link was created');
    System.assertNotEquals(null, responses[1].contentVersionId, 'The second file version was not created');
    System.assertEquals(true, responses[1].isSuccess, 'The second save was not successful');
    System.assertEquals('', responses[1].errorMessage, 'There is an error message when saving the second file');
  }

  @IsTest
  static void testSaveSignatureInvocableMixSuccessErrorAndLinks() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = acc.Id;
    request.signatureString = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
    request.title = '1 Signature for ' + acc.Name;

    SignaturePadController.Request request1 = new SignaturePadController.Request();
    request1.extension = 'jpg';
    request1.recordId = acc.Id;
    request1.signatureString = null;
    request1.title = '2 Signature for ' + acc.Name;

    Test.startTest();

    List<SignaturePadController.Response> responses = SignaturePadController.saveSignatureInvocable(
      new List<SignaturePadController.Request>{ request, request1 }
    );

    Test.stopTest();

    cdls = [
      SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(1, cdls.size(), 'There is no file linked to the account');
    System.assertEquals(cdls[0].ContentDocumentId, responses[0].contentDocumentId, 'Different First file id');
    System.assertEquals(cdls[0].Id, responses[0].contentDocumentLinkId, 'Different first file link id');
    System.assertEquals(
      cdls[0].ContentDocument.Title,
      request.title +
      '.' +
      request.extension,
      'Different first file title'
    );
    System.assertNotEquals(null, responses[0].contentVersionId, 'The first file version was not created');
    System.assertEquals(true, responses[0].isSuccess, 'The first save was not successful');
    System.assertEquals('', responses[0].errorMessage, 'There is an error message when saving the first file');
    System.assertEquals(null, responses[1].contentDocumentId, 'The second file was created');
    System.assertEquals(null, responses[1].contentDocumentLinkId, 'The second link was created');
    System.assertEquals(null, responses[1].contentVersionId, 'The second file version was created');
    System.assertEquals(false, responses[1].isSuccess, 'The second save was successful');
    System.assertEquals(
      'A signature needs to be send to the method to be able to save it.',
      responses[1].errorMessage,
      'There was not an error message when saving the second file'
    );
  }

  @IsTest
  static void testSaveSignatureInvocableAllFailed() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    List<ContentDocumentLink> cdls = [
      SELECT ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');

    SignaturePadController.Request request = new SignaturePadController.Request();
    request.extension = 'png';
    request.recordId = acc.Id;
    request.signatureString = null;
    request.title = '1 Signature for ' + acc.Name;

    SignaturePadController.Request request1 = new SignaturePadController.Request();
    request1.extension = 'jpg';
    request1.recordId = acc.Id;
    request1.signatureString = null;
    request1.title = '2 Signature for ' + acc.Name;

    Test.startTest();

    List<SignaturePadController.Response> responses = SignaturePadController.saveSignatureInvocable(
      new List<SignaturePadController.Request>{ request, request1 }
    );

    Test.stopTest();

    cdls = [
      SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :acc.Id
    ];

    System.assertEquals(0, cdls.size(), 'There is at least one file linked to the account');
    System.assertEquals(null, responses[0].contentDocumentId, 'The first file was created');
    System.assertEquals(null, responses[0].contentDocumentLinkId, 'The first link was created');
    System.assertEquals(null, responses[0].contentVersionId, 'The first file version was created');
    System.assertEquals(false, responses[0].isSuccess, 'The first save was not successful');
    System.assertEquals(
      'A signature needs to be send to the method to be able to save it.',
      responses[1].errorMessage,
      'There was not an error message when saving the first file'
    );
    System.assertEquals(null, responses[1].contentDocumentId, 'The second file was created');
    System.assertEquals(null, responses[1].contentDocumentLinkId, 'The second link was created');
    System.assertEquals(null, responses[1].contentVersionId, 'The second file version was created');
    System.assertEquals(false, responses[1].isSuccess, 'The second save was successful');
    System.assertEquals(
      'A signature needs to be send to the method to be able to save it.',
      responses[1].errorMessage,
      'There was not an error message when saving the second file'
    );
  }
}