/**
 * Minimal smoke-test class used only to validate the CI/CD pipeline
 * (scratch org deploy + RunLocalTests). Not part of the Habitat Peru
 * business requirements — safe to delete once real components exist.
 */
public with sharing class CicdPipelineCheck {
  public static String ping() {
    return 'pong';
  }
}
