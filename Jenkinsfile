import java.net.URL
import java.net.HttpURLConnection

import java.io.BufferedWriter
import java.io.OutputStreamWriter

import groovy.json.JsonSlurper
import groovy.json.JsonOutput

def response = 'curl http://169.254.169.254/latest/meta-data/placement/availability-zone '.execute().text
def region = response.substring(0, response.length() - 1)
if (region ==~ /cn.*/ ){
    groovy_prefix="docker-cn"
} else {
    groovy_prefix="docker"
}

def NotifyTeams(Map message_value, String status_color, String message_body, String message_url){

    // Format post data to teams 
    def jsonSlurper = new JsonSlurper()
    def object = jsonSlurper.parseText(message_body)
    object.themeColor = status_color
    message_value.each{ k,v ->
        def fact = ["name":k, "value":v]
        object.sections[0].facts = object.sections[0].facts << fact
    }

    def body = JsonOutput.toJson(object)
    println(body)

    // Post data to teams
    def url = new URL(message_url)

    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST")
    conn.setRequestProperty("Content-Type", "application/json")
    conn.setRequestProperty("Accept", "application/json")
    conn.doOutput = true

    def httpRequestBodyWriter = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream()))
    httpRequestBodyWriter.write(body)
    httpRequestBodyWriter.close()

    println(conn.getResponseCode())
    println(conn.getResponseMessage())

}

pipeline {

    agent any

    environment {
        REGISTRY= "seedlinktech.com:443"
        PREFIX="${groovy_prefix}"
        MESSAGE_BODY='{"@type": "MessageCard","@context": "http://schema.org/extensions","themeColor": "","summary": "Seedlink app deploying","sections": [{"activityTitle": "Deploying Message","activitySubtitle": "","activityImage": "","facts": [],"markdown": true}]}'
        RELEASE_CHANNEL='https://outlook.office.com/webhook/2ef9a42b-1c1d-49a7-b228-27b70bb6fd90@72cd245b-e6ca-4b58-b073-54fcf857eecd/IncomingWebhook/1ec9541240de41179fd4036a9aa74f58/6342dfe3-0854-47a2-8668-9b260ffd3fe8'
        SUCCESS_COLOR = "33ff33"
        FAILED_COLOR = "cc0000" 
    }


    stages {
        stage("BUILD Base") {
              parallel {
                stage('BUILD base_env and osqa base') {
                    agent any
                    steps {
                        sh '''
                              echo 'start build seedlink waf'

                              git submodule init
                              git submodule update
                              docker build --force-rm --build-arg DOCKER_GITCOMMIT=${GIT_COMMIT} --build-arg DOCKER_PREFIX=${PREFIX} \
                                     -t ${PREFIX}.seedlinktech.com:443/waf:${GIT_LOCAL_BRANCH}_${GIT_COMMIT} .
                              docker tag ${PREFIX}.seedlinktech.com:443/waf:${GIT_LOCAL_BRANCH}_${GIT_COMMIT} \
                                     ${PREFIX}.seedlinktech.com:443/waf:latest

                              docker push ${PREFIX}.seedlinktech.com:443/waf:${GIT_LOCAL_BRANCH}_${GIT_COMMIT}
                              docker push ${PREFIX}.seedlinktech.com:443/waf:latest
                           '''
        	        }
          	    }
            }
        }
    }
    post {
        success {
            script {
                def messages = [
                    "BUILD_URL":env.BUILD_ID,
                    "BUILD_NUMBER":env.BUILD_NUMBER,
                    "BUILD_URL"  :env.BUILD_URL,
                    "BUILD_STATUS": "${currentBuild.currentResult}",
                    "DOCKER_REGISTRY": "${PREFIX}.seedlinktech.com:443",
                    "DOCKER_TAG": "${env.GIT_LOCAL_BRANCH}_${env.GIT_COMMIT}",
                    "APP_NAME": "waf(mod security3)",
                    "GIT_COMMIT" :env.GIT_COMMIT,
                    "PREVIOUS_COMMIT":env.GIT_PREVIOUS_COMMIT,
                    "GIT_URL":env.GIT_URL,
                    "COMMIT_AUTHOR":env.GIT_AUTHOR_NAME,
                    "BRANCH_NAME":env.GIT_BRANCH
                ] 
                NotifyTeams(messages, env.SUCCESS_COLOR, env.MESSAGE_BODY,env.RELEASE_CHANNEL)
            }
       }
       failure {
            script {
                def messages = [
                    "BUILD_URL":env.BUILD_ID,
                    "BUILD_NUMBER":env.BUILD_NUMBER,
                    "BUILD_URL"  :env.BUILD_URL,
                    "BUILD_STATUS": "${currentBuild.currentResult}",
                    "DOCKER_REGISTRY": "${PREFIX}.seedlinktech.com:443",
                    "DOCKER_TAG": "${env.GIT_LOCAL_BRANCH}_${env.GIT_COMMIT}",
                    "APP_NAME": "waf(modsecurity3)",
                    "GIT_COMMIT" :env.GIT_COMMIT,
                    "PREVIOUS_COMMIT":env.GIT_PREVIOUS_COMMIT,
                    "GIT_URL":env.GIT_URL,
                    "COMMIT_AUTHOR":env.GIT_AUTHOR_NAME,
                    "BRANCH_NAME":env.GIT_BRANCH
                ] 
                NotifyTeams(messages, env.FAILED_COLOR, env.MESSAGE_BODY,env.RELEASE_CHANNEL)
            }
        }
    }
}
