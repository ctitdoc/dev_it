import dev_it.srv_opportunity as opp;
public function main(string app, string runConfigurationFile) returns error? {
    match app {
        "srv_opportunity" => {check opp:srv_opportunity(runConfigurationFile);}
    }
}