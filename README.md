## View our full report report [here](https://drive.google.com/file/d/1yi9pBEH1PLF4ZvZhT5gHE6RXwwPgENJU/view?usp=sharing)

# System-On-Chip Design Final Project

For the 2026 System-On-Chip Design final project, we transformed a single cycle processor into a capable pipelined processor. We optimized our processor by reducing the critical path area, optimizing hazarding, and reducing overall size. The processor achieved a score ten times larger than the original processor, with an execution time 62.4% faster. The project gave the team experience in the process of SOC development. In this report, we will cover processor optimizations, then discuss results and review the progression timeline of the project.

# Microarchitecture Specification
Our design features a 5-stage processor microarchitecture based on the RV32IM instruction set, incorporating a dedicated 3-stage multiplication unit and comprehensive hazard unit logic. The design is inspired by the pipelined processor presented in “Digital Design and Computer Architecture, RISC-V Edition” by David and Sarah Harris as well as the design of the Wally RISC-V Processor.
<img width="1273" height="807" alt="Screenshot 2026-05-01 at 12 26 42 AM" src="https://github.com/user-attachments/assets/90c8e484-10fe-4a9b-a77b-70711bc1ec82" />
<img width="806" height="514" alt="Screenshot 2026-05-01 at 12 27 40 AM" src="https://github.com/user-attachments/assets/5e47b951-5f95-48b0-9e1f-d7352a132f02" />
<img width="775" height="440" alt="Screenshot 2026-05-01 at 12 29 55 AM" src="https://github.com/user-attachments/assets/332982d8-507a-47e4-be8a-be38f165f40e" />
<img width="817" height="504" alt="Screenshot 2026-05-01 at 12 28 52 AM" src="https://github.com/user-attachments/assets/9e6be661-f066-4f39-a1ec-dee4244a9378" />
<img width="887" height="567" alt="Screenshot 2026-05-01 at 12 30 42 AM" src="https://github.com/user-attachments/assets/f6de0837-9c5f-4da1-8895-b7949d3bd4cc" />

[SOC Final Project Report Max & Pierce.pdf](https://github.com/user-attachments/files/27271204/SOC.Final.Project.Report.Max.Pierce.pdf)


[SOC Final Presentation.pdf](https://github.com/user-attachments/files/27271198/SOC.Final.Presentation.pdf)

View our processor in /examples/exercises/lynn
