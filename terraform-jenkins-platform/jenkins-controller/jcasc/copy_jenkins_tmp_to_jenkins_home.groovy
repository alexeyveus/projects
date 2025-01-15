import java.nio.file.*
import java.nio.file.attribute.*

def copyFolderContent(Path sourceDir, Path targetDir) {
    Files.walk(sourceDir).forEach { sourcePath ->
        Path targetPath = targetDir.resolve(sourceDir.relativize(sourcePath))
        if (Files.isDirectory(sourcePath)) {
            if (!Files.exists(targetPath)) {
                Files.createDirectories(targetPath)
            }
        } else {
            Files.copy(sourcePath, targetPath, StandardCopyOption.REPLACE_EXISTING)
        }
    }
}

// Define the source and target folders
def sourceFolder = Paths.get("/var/jenkins_tmp")
def targetFolder = Paths.get("/var/jenkins_home")

// Ensure target folder exists
if (!Files.exists(targetFolder)) {
    Files.createDirectories(targetFolder)
}

// Copy content from source to target
copyFolderContent(sourceFolder, targetFolder)

println "Folder content copied from ${sourceFolder} to ${targetFolder}"
