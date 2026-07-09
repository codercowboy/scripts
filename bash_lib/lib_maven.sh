#!/bin/bash

if [ ! -z "${M2_HOME}" ]; then
	echo "Skipping import functions from lib_maven.sh, they're already sourced in this shell"
	return 0
fi

export MAVEN_OPTS="-Xmx3g"

export M2_HOME="${TOOLS}/apache-maven-3.8.6"
export MVND_HOME="${TOOLS}/mvnd-0.8.2-darwin-amd64"
export PATH="${JAVA_HOME}/bin:${M2_HOME}:${M2_HOME}/bin:${MVND_HOME}/bin:${PATH}"

alias build_this="mvn -Pfull,release clean install -DskipTests=true"
alias bt="build_this"
alias clean_this="mvn -Pfull,release clean"

function build_from() {
	CMD="mvn -Pfull,release -rf :${1} clean install -DskipTests=true"
	eval "${CMD}"
}
export -f build_from

function build_restore {
	git restore  --staged pom.xml
	git restore pom.xml
	echo "Restored pom.xml"
}
export -f build_restore

function build_minimize {
	# make new 'full' profile in main pom.xml
	git restore --staged pom.xml
	git restore pom.xml
	
	cat pom.xml | sed '/profiles/q' > pom.xml.new
	echo "
		<profile>
			<id>full</id>
			<activation><activeByDefault>true</activeByDefault></activation>
			<modules>" >> pom.xml.new
	git status | grep parent \
		| sed 's/.*modified.//' | sed 's/.*new file.//' | sed 's/.*deleted.//' | sed 's/.*renamed.//' \
		| sed 's/^[^a-z]*/<module>/' | sed 's/parent.*/parent<\/module>/' | sort | uniq >> pom.xml.new
	echo "
			<module>webapp-parent</module>
			<module>product-parent</module>
			</modules>			
			<build><defaultGoal>clean site install</defaultGoal></build>
		</profile>" >> pom.xml.new
				
	cat pom.xml | sed -ne '/\/profiles/,$ p' >> pom.xml.new
	mv pom.xml.new pom.xml

	echo "Pom.xml was minimized, remaining modules:" 
	cat pom.xml | grep "<module>" | sed 's/\t*.module.//' | sed 's/parent.*/parent/'
}
export -f build_minimize