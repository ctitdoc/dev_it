
public  function shouldBeRan(string scenarioId) returns boolean {
    return runConfiguration[scenarioId] != () || runConfiguration["all"] != ();
}

public  function getRunConfiguration(string scenarioId) returns map<json>? {
    map<json> config = checkpanic runConfiguration[scenarioId].ensureType();
    return config;
}
 public function setRunConfiguration(json config) returns error? {
    runConfiguration = check config.ensureType();
 }