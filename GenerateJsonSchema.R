source("Functions.R")

# TemporalCovariateSettings ----------------------------------------------------
library(FeatureExtraction)
createFunction <- "createTemporalCovariateSettings"
instance <- FeatureExtraction::createTemporalCovariateSettings(useDemographicsGender = TRUE,
                                                               useDemographicsAge = TRUE,
                                                               useDemographicsAgeGroup = TRUE,
                                                               useDemographicsRace = TRUE,
                                                               useDemographicsEthnicity = TRUE,
                                                               useDemographicsIndexYear = TRUE,
                                                               useDemographicsIndexMonth = TRUE,
                                                               useDemographicsPriorObservationTime = TRUE,
                                                               useDemographicsPostObservationTime = TRUE,
                                                               useDemographicsTimeInCohort = TRUE,
                                                               useDemographicsIndexYearMonth = TRUE,
                                                               useConditionOccurrence = TRUE,
                                                               useConditionOccurrencePrimaryInpatient = TRUE,
                                                               useConditionEraStart = TRUE,
                                                               useConditionEraOverlap = TRUE,
                                                               useConditionEraGroupStart = TRUE,
                                                               useConditionEraGroupOverlap = TRUE,
                                                               useDrugExposure = TRUE,
                                                               useDrugEraStart = TRUE,
                                                               useDrugEraOverlap = TRUE,
                                                               useDrugEraGroupStart = TRUE,
                                                               useDrugEraGroupOverlap = TRUE,
                                                               useProcedureOccurrence = TRUE,
                                                               useDeviceExposure = TRUE,
                                                               useMeasurement = TRUE,
                                                               useMeasurementValue = TRUE,
                                                               useMeasurementRangeGroup = TRUE,
                                                               useObservation = TRUE,
                                                               useCharlsonIndex = TRUE,
                                                               useDcsi = TRUE,
                                                               useChads2 = TRUE,
                                                               useChads2Vasc = TRUE,
                                                               useHfrs = TRUE,
                                                               useDistinctConditionCount = TRUE,
                                                               useDistinctIngredientCount = TRUE,
                                                               useDistinctProcedureCount = TRUE,
                                                               useDistinctMeasurementCount = TRUE,
                                                               useDistinctObservationCount = TRUE,
                                                               useVisitCount = TRUE,
                                                               useVisitConceptCount = TRUE,
                                                               temporalStartDays = -365:-1,
                                                               temporalEndDays = -365:-1,
                                                               includedCovariateConceptIds = c(1,2,3),
                                                               addDescendantsToInclude = FALSE,
                                                               excludedCovariateConceptIds = c(1,2,3),
                                                               addDescendantsToExclude = FALSE,
                                                               includedCovariateIds = c(1,2,3))
json <- generateJsonSchema(createFunction, instance)
write(json, "TemporalCovariateSettings.json")

# CohortDiagnosticsModulepecifications ----------------------------------------
library(CohortDiagnostics)
source("https://raw.githubusercontent.com/OHDSI/CohortDiagnosticsModule/main/SettingsFunctions.R")
createFunction <- "executeDiagnostics"
instance <- createCohortDiagnosticsModuleSpecifications(runInclusionStatistics = TRUE,
                                                        runIncludedSourceConcepts = TRUE,
                                                        runOrphanConcepts = TRUE,
                                                        runTimeSeries = FALSE,
                                                        runVisitContext = TRUE,
                                                        runBreakdownIndexEvents = TRUE,
                                                        runIncidenceRate = TRUE,
                                                        runCohortRelationship = TRUE,
                                                        runTemporalCohortCharacterization = TRUE,
                                                        temporalCovariateSettings = createReference("https://raw.githubusercontent.com/schuemie/JsonSchemaTest/main/TemporalCovariateSettings.json"),
                                                        incremental = FALSE)$settings
json <- generateJsonSchema(createFunction, instance)
write(json, "CohortDiagnosticSpecifications.json")
