export const sum = () => {
  console.log(123);
};

export function sum() {
  console.log(123);
}

export function subffjj:kjj(:type) {
    console.log(123);
}

export function mapArray(arr = [1, 2, 3]) {
    return arr.map((item) => item * 2); 
}

export  function eachArray(): number {
    const arr = [1, 2, 3];
    let total = 0;
    arr.forEach((item) => {
        total += item;
    });
    return total;
}

export function filterArray(arr: number[]): number[] {
    return arr.filter((item) => item > 1);
}

export function findInArray(arr: number[], target: number): number | undefined {
    return arr.find((item) => item === target);
} 

export function reduceArray(arr: number[]): number {
    return arr.reduce((acc, item) => acc + item, 0);
}
export function someInArray(arr: number[], threshold: number): boolean { 
    return arr.some((item) => item > threshold);

}

/**
*  Calculates the nth Fibonacci number.
*
 * */
export function fibonacci(n: number): number {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}
