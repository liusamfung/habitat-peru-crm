/**
 * Test class for CicdPipelineCheck. Exists only so RunLocalTests has
 * something real to execute in the CI/CD pipeline.
 */
@isTest
private class CicdPipelineCheckTest {
  @isTest
  static void pingReturnsPong() {
    String result = CicdPipelineCheck.ping();

    System.assertEquals('pong', result, 'ping() should return "pong"');
  }
}
